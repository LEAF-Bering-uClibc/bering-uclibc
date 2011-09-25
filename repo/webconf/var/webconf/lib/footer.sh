#!/bin/sh
# Part of the web configuration system for LEAF routers
# Copyright (C) 2004 Nathan Angelacos - Licensed under terms of the GPL
# $Id: footer.sh,v 1.1 2008/04/04 09:33:40 mats Exp mats $


cat <<EOF
<!--	End						-->
<hr>
<table border=0 width=100%>
<tr><td align=left valign=top><a href="#PageTop">Top</a></td>
<td align=center valign=top><i>This page was generated $(date)<br>
for $REMOTE_ADDR by webconf running on $(hostname)<br>
$1<br>
</td>
<td align=right valign=top><a href="/">Home</a></td></tr>
</table>
</div></td></tr></table></body></html>
