
function toggle_active(element_name,caller)
{
        set_active(element_name,caller.checked ? "false" : "true")
}

function toggle_dhcp(element_name,caller)
{
        set_dhcp(element_name,caller.checked ? "true" : "false")
}

function toggle_pppoe(element_name,caller)
{
        set_pppoe(element_name,caller.checked ? "true" : "false")
}

function set_active(element_name,value)
{
	var to_eval="document.forms[0]." + element_name + "_addr.disabled=" + value;
	eval (to_eval);
	to_eval="document.forms[0]." + element_name + "_mask.disabled=" + value;
	eval (to_eval);
	to_eval="document.forms[0]." + element_name + "_dhcp.disabled=" + value;
	eval (to_eval);
	to_eval="document.forms[0]." + element_name + "_pppoe.disabled=" + value;
	eval (to_eval);
}

function set_dhcp(element_name,value)
{
	var to_eval="document.forms[0]." + element_name + "_addr.disabled=" + value;
	eval (to_eval);
	to_eval="document.forms[0]." + element_name + "_mask.disabled=" + value;
	eval (to_eval);
	if (element_name == "eth0") {
		to_eval="document.forms[0]." + element_name + "_pppoe.disabled=" + value;
		eval (to_eval);
	}

	gateway_address=get_gateway_address();
	interface_address=eval("document.forms[0]." + element_name + "_addr.value")
	if(gateway_address == interface_address) {
		to_eval="document.forms[0]." + "gateway.disabled=" + value;
		eval (to_eval);
	}
}

function set_pppoe(element_name,value)
{
	var to_eval="document.forms[0]." + element_name + "_addr.disabled=" + value;
	eval (to_eval);
	to_eval="document.forms[0]." + element_name + "_mask.disabled=" + value;
	eval (to_eval);
	if (element_name == "eth0") {
		to_eval="document.forms[0]." + element_name + "_dhcp.disabled=" + value;
		eval (to_eval);
		to_eval="document.forms[0]." + "gateway.disabled=" + value;
		eval (to_eval);
		document.all["ppp_link"].style.display  = (value == "true" ? "inline" : "none");
	}
}

function get_gateway_address()
{
        var gateway_address=document.forms[0].gateway.value;
	return gateway_address;
}
                                       
