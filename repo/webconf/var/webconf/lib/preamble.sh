#!/bin/sh
# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# $Id: preamble.sh,v 1.4 2008/11/28 13:28:56 etitl Exp $
#
# erich.titl@think.ch
# added call to passcheck.sh to force the use of a .htpasswd file
#

# If we don't have a FORM_UI, then get the default UI from /etc/webconf/webconf.conf
# 

if [ -z "$FORM_UI" -a -f /etc/webconf/webconf.conf ] ; then
	. /etc/webconf/webconf.conf 2>/dev/null
	FORM_UI=$UI
	[ -z "$FORM_UI" ] && FORM_UI="basic"
	fi

cat <<-EOF
Cache-Control: no-cache
Expires: Tue, 01 Jan 1980 00:00:00 GMT
Content-Type: text/html
Set-Cookie: UI=${FORM_UI:-${UI}}; path=/;

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
$( /var/webconf/lib/passcheck.sh )
<title>Bering LEAF Firewall</title>
<link rel="stylesheet" type="text/css" href="/webconf.css">
</head>
<body marginwidth="0" marginheight="0" leftmargin="0" rightmargin="0" topmargin="0" bgcolor="#FFFFFF" text="#000000" link="#336699">

<!-- The header -->
<a name="PageTop">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td class="blueback" valign="bottom">
<img src="/pix/logo1.gif" width="328" height="33" alt="" border="0"></td>
<td class="blueback" align="right" width="100%">
<font class="blueback">$( echo -n "This is: $(hostname)&nbsp;&nbsp;" )</font></td></tr>


<tr><td valign="top" align="left">
<img src="/pix/logo2.gif" width="328" height="16" alt=""></td>
<td align=center><b>$( echo -n "$title" )</b></td></tr>
<tr><td><br></td></tr>
</table>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<!-- Begin Menu -->
<td width=15% valign=top>
$( /var/webconf/lib/menubuilder.sh "$FORM_UI" )
</td>
<!-- End Menu, begin content -->

<td width="2em" bgcolor="#cccccc">
</td>
<td valign="top">
<div id="Content">
EOF
