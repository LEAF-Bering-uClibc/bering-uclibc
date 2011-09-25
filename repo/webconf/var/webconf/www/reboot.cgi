#!/usr/bin/haserl
<% title="Linux Embedded Network Appliance"  /var/webconf/lib/preamble.sh  %>
<!-- $Id: index.cgi,v 1.2 2004/11/10 21:57:40 nangel Exp $ -->

   
<% # Print out the blurb for the specific user interface
   # Preamble should have set FORM_UI for us

   UI=${FORM_UI:-"basic"}
   echo "<p>Rebooting....</p>" 

   /var/webconf/lib/footer.sh
   echo "<pre>"
   /sbin/reboot
   echo "</pre>"

%>

