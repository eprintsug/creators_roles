/** 
 * Javascript to support CRediT field
 */
var credit_roles = {};
var credit_sizes = {};
var credit_sizes_long = {};

fetch("/cgi/ajax/credit_roles", {method:'get', credentials: 'same-origin'})
.then(resp => {
  console.log(resp.status + " " + resp.statusText);
    if (resp.status > 399)
    {
        throw new Error(resp.status + " " + resp.statusText);
    }
    return resp.json();
})
.then(json => {
  credit_roles = json["credit_roles"];
  credit_sizes_short = json["credit_sizes_short"];
  credit_sizes_long = json["credit_sizes_long"];
})
.catch((e) => console.error("error", e));
  
function get_cr_value_in(opts_panel_id)
{
  var value_in_id = opts_panel_id.replace("_optspanel", "");
  return document.getElementById(value_in_id);
}

function is_role_selected(opts_panel_id, role_id)
{
  var value_in = get_cr_value_in(opts_panel_id);
  return value_in.value.indexOf(role_id) != -1;
}

function credit_options_open(ele)
{
    var opts_panel_id = ele.id.replace("_optsbtn_open", "_optspanel");
    var close_btn = document.getElementById(ele.id.replace("_open", "_close"))

    // TODO a position: absolute etc to make it go over top
    var panelHTML = `<div id="${opts_panel_id}" class="credit_options"></div>`;
    close_btn.insertAdjacentHTML("afterend", panelHTML);
    ele.addClassName("cr-hidden");
    close_btn.removeClassName("cr-hidden");
    display_opts_buttons(opts_panel_id);
}

function credit_options_close(ele)
{
    var opts_panel_id = ele.id.replace("_optsbtn_close", "_optspanel");
    var opts_panel = document.getElementById(opts_panel_id);
    var open_btn = document.getElementById(ele.id.replace("_close", "_open"));
    opts_panel.innerHTML = "";
    opts_panel.remove();
    ele.addClassName("cr-hidden");
    open_btn.removeClassName("cr-hidden");
    return;
}

function display_opts_buttons(opts_panel_id) 
{
    var opts_panel = document.getElementById(opts_panel_id);
    opts_panel.innerHTML = "";
     for (var role_id of Object.keys(credit_roles))
     {
        var div = document.createElement("div");
        div.setAttribute("class", "cr-line");
        opts_panel.appendChild(div);
        var selected = is_role_selected(opts_panel_id, role_id);
        div.appendChild(create_cr_button(opts_panel_id, role_id, '', credit_roles[role_id], credit_roles[role_id], selected));
        for (var size of Object.keys(credit_sizes_short))
        {
          var selected = is_role_selected(opts_panel_id, role_id +"-" + size);
          div.appendChild(create_cr_button(opts_panel_id, role_id, size, credit_sizes_short[size], credit_sizes_long[size], selected));
        }       
     } 
 };

 function create_cr_button(opts_panel_id, role_id, size, label, aria_label, selected)
 {
    var button = document.createElement("button");
    button.innerHTML = label;
    button.setAttribute("id", opts_panel_id + "_btn_" + role_id);
    button.setAttribute("type", "button");
    button.setAttribute("onClick", "toggle_credit_role(this, '"+ role_id +"','" + size + "')");
    button.setAttribute("aria-labelledby", aria_label);
    button.addClassName("cr-btn");
    button.addClassName(label.length < 3 ? "cr-btn-small" : "cr-btn-large");
    if (selected)
    {
        button.addClassName("cr-btn-selected");
    }
    return button;
 }

 function cr_make_key(role_id, size)
 {
    return size == '' ? role_id : role_id + "-" + size;

 }

 function toggle_credit_role(ele, role_id, size)
 {
    var value_in_id = ele.id.substring(0, ele.id.indexOf("credit_roles")+12);
    var value_in = document.getElementById(value_in_id);
    var roles_selected = value_in.value.split(" ");
    
    // If nothing on the row is hightlighted or the size has changed then 
    // this is a new entry
    var is_new = true;

    // Unhighlight default and size options
    var roles_to_remove = [cr_make_key(role_id, '')];
    for (var credit_size of Object.keys(credit_sizes_short))
    {
      roles_to_remove.push(cr_make_key(role_id,credit_size));
    }

    for (var role_to_remove of roles_to_remove)
    {
      if (roles_selected.indexOf(role_to_remove) != -1)
      {
        if (size == "" || role_to_remove == cr_make_key(role_id,size))
        {
          is_new = false;
        }
        roles_selected.splice(roles_selected.indexOf(role_to_remove), 1);
      }
    }

    // If the role was not there originally then insert it
    if (is_new)
    {
      roles_selected.push(cr_make_key(role_id,size));
    }

    value_in.value = roles_selected.join(" ");
    update_cr_display(value_in_id);
    display_opts_buttons(value_in_id + "_optspanel") 
 }

 function update_cr_display(value_in_id)
 {
    var cr_display_id = value_in_id + "_display";
    var cr_display = document.getElementById(cr_display_id);
    var value_in = document.getElementById(value_in_id);
    var roles_selected = value_in.value.split(" ");
    var cr_display_contents = [];
    for (var role_id of Object.keys(credit_roles))
    {
        if(roles_selected.indexOf(role_id) != -1)
        {
          cr_display_contents.push(credit_roles[role_id]);
        }
        for (var size of Object.keys(credit_sizes_short))
        {
          if(roles_selected.indexOf(role_id +"-" + size) != -1)
          {
            cr_display_contents.push(credit_roles[role_id] + " (" + credit_sizes_long[size] + ")" );
          }
       }       
    } 
    cr_display.value = cr_display_contents.join(", ");
 }