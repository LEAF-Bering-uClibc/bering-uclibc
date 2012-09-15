# Tools library for uclibc-bering
# (C) 2012 Yves Blusseau
# This software is distributed under the GNU General Public Licence,
# please see the file COPYING

package buildtool::Tools;

use strict;
use warnings;

use Exporter ();
use Carp;
use File::Spec;
use File::Path qw< make_path remove_tree >;

use vars qw< @ISA @EXPORT_OK %EXPORT_TAGS >;

BEGIN {
    @ISA       = qw{ Exporter };
    @EXPORT_OK = qw{
      create_dir  check_env  debug  expand_variables  expand_config_variables
      logme  make_absolute_path  readBuildtoolConfig  remove_dir
      set_environment
      };
    %EXPORT_TAGS = ( ALL => \@EXPORT_OK, );
}

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
    $envvars = {} if not defined $envvars;

    croak "First argument must be defined" if not defined $string;

    my $loop = 0;

    # expand variables
    while ( $string =~ /\$(\w+)\b/ ) {
        my $value;
        $loop++;
        if ($loop > 16) { # Avoid infinite loop
            die "Error: infinite loop found trying to expand '\$$1' variable\n";
        }
        if ( exists $envvars->{ uc($1) } ) { # Get the value from envvars
            $value = $envvars->{ uc($1) };
        }  elsif ( exists $hash->{ lc($1) } ) {    # Get the value from hash
            $value = $hash->{ lc($1) };
        } else {
            die "Error: can't expand variable \$$1\n";
        }
        $string =~ s/\$$1\b/$value/g;
    }
    return $string;
}

###############################################################################
# expand variables from a config hash
# use optionnal hash ref argument to resolv variables to values
sub expand_config_variables {
    my ( $config, $globalconfig ) = @_;

    # Use optional global config
    $globalconfig = $config if not defined $globalconfig;

    foreach my $key ( keys %{$config} ) {
        if ( not ref( $config->{$key} ) ) {    # it's a scalar
            $config->{$key} = expand_variables( $config->{$key}, $globalconfig,
                                                $config->{envvars} );
        } elsif ( ref( $config->{$key} ) eq 'ARRAY' ) {    # it's an array
            # expand every item in the array
            $config->{$key} = [
                map {
                    expand_variables( $_, $globalconfig, $config->{envvars} )
                  } @{ $config->{$key} }
            ];
        } elsif ( $key ne 'envvars' and ref( $config->{$key} ) eq 'HASH' ) {
            # expand variable recursively
            expand_config_variables( $config->{$key},
                                   { %{$globalconfig}, %{ $config->{$key} } } );
        }
    }
}

###############################################################################
# read the buildtool configuration file and expand all variables
# return a hash with all values expanded
sub readBuildtoolConfig {
    my (@args) = @_;
    my %args;
    if (@args % 2 == 0) {
        %args = @args;
    } else {
        croak "odd number of arguments";
    }

    my $configfile = delete $args{ConfigFile}
      or croak "Parameter ConfigFile required !";
    my $forceconfig = delete $args{ForceConfig} || {};

    my $rest = ( keys %args )[0];
    croak "Unknown argument '$rest'" if defined $rest;

    my $defaultconfig = {
                          'log_dir'     => 'log',
                          'conf_dir'    => 'conf',
                          'tools_dir'   => 'tools',
                          'source_dir'  => 'source/$toolchain',
                          'staging_dir' => 'staging/$toolchain',
                          'package_dir' => 'package/$toolchain',
                          'image_dir'   => 'image',
                        },

    # load the buildtool configuration file
    my %btconfig =
      Config::General::ParseConfig(
                                    "-ConfigFile"           => $configfile,
                                    "-LowerCaseNames"       => 1,
                                    "-MergeDuplicateBlocks" => 1,
                                  );

    my $localConfigFile;
    ($localConfigFile = $configfile) =~ s/\.conf$/.local/;

    my %btLocalConfig = ();
    if ( -f $localConfigFile ) {
        %btLocalConfig =
          Config::General::ParseConfig(
                                        "-ConfigFile"     => $localConfigFile,
                                        "-LowerCaseNames" => 1,
                                        "-MergeDuplicateBlocks" => 1,
                                      );

        # Merge the two config file
        for my $key ( keys %btLocalConfig ) {
            if ( exists $btconfig{$key} and ref $btconfig{$key} ) {
                if ( ref $btconfig{$key} eq 'HASH' ) {
                    # Merge the hash
                    $btconfig{$key} =
                      { %{ $btconfig{$key} }, %{ $btLocalConfig{$key} } };
                } elsif ( ref $btconfig{$key} eq 'ARRAY' ) {
                    # Merge the array
                    my @localvalues;
                    if ( ref $btLocalConfig{$key} eq 'ARRAY' ) {
                        @localvalues = @{ $btLocalConfig{$key} };
                    } elsif ( ref $btLocalConfig{$key} eq 'HASH' ) {
                        @localvalues = %{ $btLocalConfig{$key} };
                    } else {
                        @localvalues = ( $btLocalConfig{$key} );
                    }
                    $btconfig{$key} = [ @{ $btconfig{$key} }, @localvalues ];
                } else {
                    # Must must not go there
                    confess "Error must not go there !";
                }
            } else {
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
# Set environment variables from builtool config envvars
# return an array with name of variables that has been set
sub set_environment {
    my ($btConfig) = @_;
    return
      map { $ENV{$_} = $btConfig->{'envvars'}->{$_}; $_ }
      keys %{ $btConfig->{'envvars'} };
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
