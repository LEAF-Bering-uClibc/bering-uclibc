# Tools library for uclibc-bering
# (C) 2012 Yves Blusseau
# This software is distributed under the GNU General Public Licence,
# please see the file COPYING

package buildtool::Tools;

use strict;
use warnings;

use Exporter ();
use Carp;

use Config::General qw(ParseConfig);
use File::Spec;
use File::Path qw< make_path remove_tree >;

use vars qw< @ISA @EXPORT_OK %EXPORT_TAGS >;

BEGIN {
    @ISA       = qw{ Exporter };
    @EXPORT_OK = qw{
      create_dir  check_env  debug  expand_variables  expand_config_variables
      logme  make_absolute_path  remove_dir
      readBtConfig readBtGlobalConfig
      };
    %EXPORT_TAGS = ( ALL => \@EXPORT_OK, );
}

#
# set the regex for finding vars
#
my $vars_regex = qr{
                      \$        # dollar sign
                      (\()?     # $1: optional opening parenthesis
                      (\w+)     # $2: capturing variable name
                      (
                          ?(1)  # $3: if there's the opening parenthesis...
                          \)    #     ... match closing parenthesis
                      )
              }xo;

my $package_valid_key_regex = qr{
                                    ^               # start from the begining
                                    (?:             # start group without capturing
                                        contents|
                                        dependson|
                                        help|
                                        license|
                                        owner|
                                        permissions|
                                        packagename|
                                        packagetype|
                                        revision|
                                        version
                                    )               # end group
                                    $               # match the end
                            }xio;

# detect lines like: ?include <filename>
my $conditional_include_regex = qr{
                                   ^            # begining of the line
                                   \s*          # follow by zero or more space
                                   \?           # start with ?
                                   \s*          # follow by zero or more space
                                   include      # word include
                                   \s+          # follow by one or more space
                                   <            # open <
                                     \s*        # follow by zero or more space
                                     (.+)       # capture filename
                                     \s*        # follow by zero or more space
                                   >            # close >
                              }xio;

my $logfile_fh;

###############################################################################
# init log file
#
sub init_log_file {
    my ($btConfig) = @_;

    # make sure, log dir is there
    create_dir(
        make_absolute_path( $btConfig->{'log_dir'}, $btConfig->{'root_dir'} ) );

    # make the logfile absolute
    my $logfile =
      make_absolute_path( $btConfig->{'logfile'}, $btConfig->{'root_dir'} );
    $btConfig->{'logfile'} = $logfile;    # Store the absolute path

    # open log
    open $logfile_fh, ">> $logfile"
      or die "Cannot open logfile '$logfile':$!";

    # allow anybody to read/write
    chmod 0666, $logfile;
}

###############################################################################
# print something to the logfile
#
sub logme {
    my $btConfig = shift;
    if ( $btConfig->{'debugtologfile'} ) {
        init_log_file($btConfig) unless $logfile_fh;
        print $logfile_fh join( "", @_ ) . "\n";
    }
}

###############################################################################
# a debug routine for later purposes...
#
sub debug {
    my $btConfig = shift;
    if ( $btConfig->{'debugtoconsole'} ) {
        print join( "", @_ ) . "\n";
    }
    logme( $btConfig, @_ );
}

###############################################################################
# create directory if not exists
sub create_dir {
    my ($dirname) = @_;
    if ( ! -d $dirname ) {
        # create the dir
        make_path( $dirname, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    croak "error: $message\n";
                } else {
                    croak "can't create directory '$dir': $message\n";
                }
            }
        }
        chmod 0777, $dirname;
    }
}

###############################################################################
# remove directory and subdirectories
sub remove_dir {
    my ($dirname) = @_;
    if ( -d "$dirname" ) {
        # create the dir
        remove_tree( $dirname, { error => \my $err } );
        if (@$err) {
            for my $diag (@$err) {
                my ( $dir, $message ) = %$diag;
                if ( $dir eq '' ) {
                    croak "error: $message\n";
                } else {
                    croak "can't remove directory '$dir': $message\n";
                }
            }
        }
    }
}

###############################################################################
# return an absolute path
sub make_absolute_path {
  my ($path, $rootdir) = @_;
  croak "rootdir must not be empty" unless $rootdir;
  return File::Spec->rel2abs( $path, $rootdir );
}

###############################################################################
# expand variables from scalar pass in the first argument
# hash ref arguments to resolv variables to values
sub expand_variables {
    my ( $string, $hash, $envvars ) = @_;
    $envvars = $hash->{envvars} || {} if not defined $envvars;

    croak "First argument must be defined" if not defined $string;


    my $loop = 0;

    # expand variables
    while ( $string =~ $vars_regex ) {
        my $var = $2;
        my $value;

        if ($loop++ > 16) { # Avoid infinite loop
            die "Error: infinite loop found trying to expand '\$$var' variable\n";
        }
        if ( exists $envvars->{ uc($var) } ) {    # Get the value from envvars
            $value = $envvars->{ uc($var) };
            warn "warning: environment variable \$$var mask local one\n"
              if exists $hash->{ lc($var) };
        } elsif ( exists $hash->{ lc($var) } ) {  # Get the value from hash
            $value = $hash->{ lc($var) };
        } else {
            die "Error: can't expand variable \$$var\n";
        }
        $string =~ s//$value/;
    }

    return $string;
}

###############################################################################
# expand variables from a config hash
# use optionnal hash ref argument to resolv variables to values
sub expand_config_variables {
    my ( $config, $globalconfig, $envvars ) = @_;

    # Use optional global config
    $globalconfig = $config if not defined $globalconfig;

    $envvars = $globalconfig->{envvars} || {} if not defined $envvars;

    foreach my $key ( keys %{$config} ) {
        # check if the key need to be expand
        my $key_expand = expand_variables( $key, $globalconfig, $envvars );
        if ($key ne $key_expand) {
            # Update the key
            $config->{$key_expand} = delete $config->{$key};
            $key = $key_expand;
        }
        if ( not ref( $config->{$key} ) ) {    # it's a scalar
            $config->{$key} = expand_variables( $config->{$key}, $globalconfig,
                                                $config->{envvars} );
        } elsif ( ref( $config->{$key} ) eq 'ARRAY' ) {    # it's an array
            # expand every item in the array
            $config->{$key} = [
                map {
                    if ( ref $_ ) {
                        if ( ref $_ eq 'HASH' ) {
                            expand_config_variables(
                                                    $_,
                                                    { %{$globalconfig}, %{$_} },
                                                    $globalconfig->{envvars}
                                                   );
                            $_;
                        }
                    } else {
                        expand_variables( $_, $globalconfig,
                                          $config->{envvars} );
                    }
                  } @{ $config->{$key} }
            ];
        } elsif ( $key ne 'envvars' and ref( $config->{$key} ) eq 'HASH' ) {
            # expand variable recursively
            expand_config_variables(
                                     $config->{$key},
                                     { %{$globalconfig}, %{ $config->{$key} } },
                                     $globalconfig->{envvars}
                                   );
        }
    }
}

###############################################################################
# Read a config file in memory and include conditional included file
# Options:
#   IncludedFileMustExists => if true included file must exists
# return a string that is the content of the file
sub _readBtFile {
    my (%params) = @_;
    my @file_contents = ();
    my ( $inputfh, $line );

    my $filename = delete $params{filename}
      or croak "Parameter filename required !";

    # Can we open the file ?
    if ( not open( $inputfh, $filename ) ) {
        if (
            exists $params{included_file}    # it's an included file
            and $params{IncludedFileMustExists} == 0
          ) {
            return '';                       # return an empty line
        }
        croak "Could not open file '$filename'\n";
    }
    my ( undef, $path, $file ) = File::Spec->splitpath($filename);

    while ( $line = <$inputfh> ) {
        # Replace #include <filename> with the contents of "filename"
        if ( $line =~ /$conditional_include_regex/ig ) {
            # avoid endless loops
            if ( $filename ne $1 ) {
                my $includedFileContent = _readBtFile(
                    %params,
                    included_file => 1,
                    filename      => File::Spec->catfile( $path, $1 )
                );
                $line =~ s/$conditional_include_regex/$includedFileContent/igs;
            }
        }
        push( @file_contents, $line );
    }
    close($inputfh);

    return join( '', @file_contents, "\n" );
}

###############################################################################
# read a config file and merge with a local file (if exists) then expand all
# variables.
# Options:
#       ForceConfig   => hash ref containing key => values pairs to force
#       DefaultConfig => hash ref containing key => value to define if not
#                        exists
#
# return a hash with all values expanded
sub readBtConfig {
    my (@args) = @_;
    my %args;
    if (@args % 2 == 0) {
        %args = @args;
    } else {
        croak "odd number of arguments";
    }

    my $configfile = delete $args{ConfigFile}
      or croak "Parameter ConfigFile required !";
    my $forceconfig            = delete $args{ForceConfig}            || {};
    my $defaultconfig          = delete $args{DefaultConfig}          || {};
    my $includedfilemustexists = delete $args{IncludedFileMustExists} || 0;

    my $rest = ( keys %args )[0];
    croak "Unknown argument '$rest'" if defined $rest;

    # load the file content
    my $fileContent = _readBtFile(
        %args,
        IncludedFileMustExists => $includedfilemustexists,
        filename               => $configfile
    );

    # load the buildtool configuration file
    my %btconfig = Config::General::ParseConfig(
        "-String"          => $fileContent,
        "-LowerCaseNames"  => 1,
        '-IncludeRelative' => 1,
        '-IncludeGlob'     => 1,
    );

    # A local file have the same name has the global one but with
    # .local extension
    my $localConfigFile;
    ( $localConfigFile = $configfile ) =~ s/\.(conf|cfg)$/.local/;

    my %btLocalConfig = ();
    if ( -f $localConfigFile ) {

        # load the file content
        $fileContent = _readBtFile(
            %args,
            IncludedFileMustExists => $includedfilemustexists,
            filename               => $localConfigFile
        );

        %btLocalConfig = Config::General::ParseConfig(
            "-String"          => $fileContent,
            "-LowerCaseNames"  => 1,
            '-IncludeRelative' => 1,
            '-IncludeGlob'     => 1,
        );

        # Merge the two config file
        for my $key ( keys %btLocalConfig ) {
            if ( exists $btconfig{$key} and ref $btconfig{$key} ) {
                if ( ref $btconfig{$key} eq 'HASH' ) {
                    # Merge the hash
                    $btconfig{$key} =
                      { %{ $btconfig{$key} }, %{ $btLocalConfig{$key} } };
                }
                elsif ( ref $btconfig{$key} eq 'ARRAY' ) {
                    # Merge the array
                    my @localvalues;
                    if ( ref $btLocalConfig{$key} eq 'ARRAY' ) {
                        @localvalues = @{ $btLocalConfig{$key} };
                    }
                    elsif ( ref $btLocalConfig{$key} eq 'HASH' ) {
                        @localvalues = %{ $btLocalConfig{$key} };
                    }
                    else {
                        @localvalues = ( $btLocalConfig{$key} );
                    }
                    $btconfig{$key} = [ @{ $btconfig{$key} }, @localvalues ];
                }
                else {
                    # Must must not go there
                    confess "Error must not go there !";
                }
            }
            else {
                $btconfig{$key} = $btLocalConfig{$key};   # Overwrite the option
            }
        }
    }

    # Overwrite config
    for my $key (keys %{$forceconfig}) {
        $btconfig{ lc($key) } = $forceconfig->{$key};
    }

    # Add defaultconfig keys if not exists
    for my $key ( keys %{$defaultconfig} ) {
        my $lkey = lc($key);    # Convert to LowerCase
        if ( not exists $btconfig{$lkey} and defined $defaultconfig->{$key} ) {
            $btconfig{$lkey} = $defaultconfig->{$key};
        }
    }

    # Check keywords defined for package(s)
    my @packages = keys %{$btconfig{package}};
    for my $pkg (@packages) {
        for my $key ( keys %{ $btconfig{package}->{$pkg} } ) {
            die "Error unknown key '$key' in file '$configfile'"
              . " for package '$pkg'\n"
              unless $key =~ $package_valid_key_regex;
        }
    }

    # Convert envvars keys to uppercase
    $btconfig{envvars} =
      { map { uc $_ => $btconfig{envvars}->{$_} }
        keys %{ $btconfig{envvars} } };

    # Expand environment variables
    for my $key ( keys %{ $btconfig{envvars} } ) {
        my $value = $btconfig{envvars}->{$key};
        if ( not ref $value ) {
            # Expand value from scalar in %btconfig or envvars hash
            $value = expand_variables( $value, \%btconfig, $btconfig{envvars} );
            $btconfig{envvars}->{$key} = $value;
        }
    }

    # Rewrite all values to expand variables
    expand_config_variables( \%btconfig );

    return %btconfig;
}

###############################################################################
# read the buildtool.conf and buildtools.local (if exists)
# return a hash with all values expanded
sub readBtGlobalConfig {
    my $defaultconfig = {
                          'log_dir'     => '$Root_Dir/log',
                          'conf_dir'    => '$Root_Dir/conf',
                          'tools_dir'   => '$Root_Dir/tools',
                          'source_dir'  => '$Root_Dir/source/$toolchain',
                          'staging_dir' => '$Root_Dir/staging/$toolchain',
                          'package_dir' => '$Root_Dir/package/$toolchain',
                          'image_dir'   => '$Root_Dir/image',
                        };
    return readBtConfig( 'DefaultConfig' => $defaultconfig, @_ );
}

###############################################################################
# checks the build environment (dirs and...)
sub check_env {
    my ($btConfig) = @_;
    logme( $btConfig, "checking build environment" );

    my @dirs = @{ $btConfig->{'buildenv_dir'} };
    foreach my $dir (@dirs) {
        # Directories must be absolute
        die "The directory $dir must be absolute"
          unless File::Spec->file_name_is_absolute($dir);
        if (not -d $dir) {
            debug( $btConfig, "making directory $dir" );
            create_dir $dir; # create the directory
            die "cannot create direcroty $dir" unless -w $dir;
        }
    }

    #check_lib_link();

    # check if we should trace:
    if ( $btConfig->{'usetracing'} ) {

        # disable it until it is found in the path:
        $btConfig->{'usetracing'} = 0;

        # try to load tracer
        eval "use buildtool::Common::FileTrace";
        if ($@) {
            die( "loading  buildtool::Common::FileTrace failed!",
                 "if you want to use file tracing support install File::Find" );
        }

        $btConfig->{'usetracing'} = 1;
        logme( $btConfig, "enabling file tracing support" );
    } else {
        logme( $btConfig, "trace support not enabled in configfile" );
    }
}

1;
