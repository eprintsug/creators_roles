/** 
 * Javascript to support CRediT field
 */
let credit_roles = {};
let credit_roles_order = [];
let credit_sizes = {};
let credit_sizes_order = [];
let credit_sizes_short = {};
let credit_sizes_long = {};
let credit_phrases = {};
let cr_search_mode = 0;

document.addEventListener("DOMContentLoaded", () => {
  cr_setup();
});

function cr_setup()
{
  fetch("/cgi/ajax/credit_roles", {method:'get', credentials: 'same-origin'})
  .then(resp => {
    if (resp.status > 399)
    {
        throw new Error(resp.status + " " + resp.statusText);
    }
    return resp.json();
  })
  .then(json => {
    credit_roles = json["credit_roles"];
    credit_roles_order = json["credit_roles_order"];
    credit_sizes_short = json["credit_sizes_short"];
    credit_sizes_long = json["credit_sizes_long"];
    credit_sizes_order = json["credit_sizes_order"];
    credit_phrases = json["credit_phrases"];

    // if search control is displayed then populate it
    if (document.getElementById("creators_credit_roles_optspanel") != null)
    {
      cr_search_mode = 1;
      cr_display_opts_buttons("creators_credit_roles_optspanel");

    }  
  })
  .catch((e) => console.error("error", e));
}

function get_cr_value_in(opts_panel_id)
{
  let value_in_id = opts_panel_id.replace("_optspanel", "");
  return document.getElementById(value_in_id);
}

function get_credit_roles(credit_roles_id)
{
  let value = document.getElementById(credit_roles_id).value;
  if (value != null && value != "")
  {
    return JSON.parse(value);
  }
  return {};
}

function set_credit_roles(opts_panel_id, value)
{
  let id = opts_panel_id.replace("_optspanel", "");
  if (value != null && value != "")
  {
    document.getElementById(id).value = JSON.stringify(value);
  }
}

// Triggered when a user clicks Open/Close next to a CR values display
function credit_options_toggle(ele)
{  
  let opts_panel_id = ele.id.replace("_optsbtn_toggle", "_optspanel");
  if (ele.getAttribute("aria-expanded") === "true")
  {
    // close
    ele.setAttribute("aria-expanded", "false");
    ele.textContent = credit_phrases["credit_optsbtn_open"]; 
    let opts_panel = document.getElementById(opts_panel_id);
    opts_panel.textContent = "";
    opts_panel.remove();
    return;
  }
  // otherwise open/create for this field
  ele.textContent = credit_phrases["credit_optsbtn_close"];
  ele.setAttribute("aria-expanded", true);
  let panelHTML = `<div id="${opts_panel_id}" class="credit_options" aria-role="listbox"></div>`;
  ele.insertAdjacentHTML("afterend", panelHTML);
  cr_display_opts_buttons(opts_panel_id);
}

function cr_display_opts_buttons(opts_panel_id) 
{
    let isFirst = true;
    let opts_panel = document.getElementById(opts_panel_id);
    opts_panel.textContent = ""; 

    let roles = get_credit_roles(opts_panel_id.replace("_optspanel", ""));
     for (let role_id of credit_roles_order)
     {
        let div = document.createElement("div");
        div.setAttribute("class", "cr-line");
        opts_panel.appendChild(div);
        let selected = role_id in roles;
        let role_btn = create_cr_button(opts_panel_id, role_id, '_', credit_roles[role_id], opts_panel_id.replace(/\d*\_credit\_roles\_optspanel/, "credit_roles_label"), selected); 
        div.appendChild(role_btn);
        if (isFirst)
        {
          role_btn.focus();
          isFirst = false;
        }
        for (let size of credit_sizes_order)
        {
          let selected = role_id in roles && roles[role_id].indexOf(size) != -1;
          div.appendChild(create_cr_button(opts_panel_id, role_id, size, credit_sizes_short[size], credit_sizes_long[size], selected));
        }       
     } 
 }

 function create_cr_button(opts_panel_id, role_id, size, label, aria_labelledby, selected)
 {
    let button = document.createElement("button");
    button.textContent = label;
    button.setAttribute("id", opts_panel_id + "_btn_" + cr_make_key(role_id, size));
    button.setAttribute("type", "button");
    button.setAttribute("onClick", "cr_toggle(this, '"+ role_id +"','" + size + "')");
    button.setAttribute("aria-label", cr_make_btn_long_label(role_id, size));
    button.setAttribute("aria-role", "option");
    button.addClassName("cr-btn");
    button.addClassName(label.length < 3 ? "cr-btn-small" : "cr-btn-large");
    if (selected)
    {
        button.addClassName("cr-btn-selected");
        button.setAttribute("aria-selected", "true");
    }
    else 
    {
      button.setAttribute("aria-selected", "false");
    }
    return button;
 }

 function cr_make_key(role_id, size)
 {
    return size == '_' ? role_id : role_id + "-" + size;
 }

 function cr_toggle(ele, role_id, size)
 {
    let credit_roles_id = ele.id.substring(0, ele.id.indexOf("credit_roles")+12);
  
    let roles = get_credit_roles(credit_roles_id);

    if (role_id in roles)
    {
      if (roles[role_id].indexOf(size) == -1)
      {
        roles[role_id] = cr_search_mode ? roles[role_id] += size : roles[role_id] = size;
      }
      else 
      {
        roles[role_id] = roles[role_id].replace(size, "");
      }
    }
    else 
    {
      roles[role_id] = size;
    }

    // If key value now blank then remove it
    if (roles[role_id] == "")
    {
      delete roles[role_id];
    }


    set_credit_roles(credit_roles_id, roles);
    cr_update_display(credit_roles_id);
    cr_display_opts_buttons(credit_roles_id + "_optspanel") 
 }

 // Update panel that says "Writer + 3" etc
 function cr_update_display(credit_roles_id)
 {
    let cr_display_id = credit_roles_id + "_display";
    let cr_display = document.getElementById(cr_display_id);
    let cr_display_contents;
    let roles = get_credit_roles(credit_roles_id);
    let keys = Object.keys(roles); 

    if (keys.length == 0)
    {
      cr_display.value = "";
      return;
    }
    
    cr_display_contents = credit_roles[keys[0]];
    let sizes = roles[keys[0]].split("");
    let size_display = [];
    for (let size of sizes)
    {
      if (size != '_')
      {
        size_display.push(credit_sizes_long[size]);
      }
    }
  
    if (size_display.length != 0)
    {
      cr_display_contents += "(" + size_display.join(",") + ")";
    }
    if (keys.length > 1)
    {
       cr_display_contents += " + " + keys.length;
    }

    cr_display.textContent = cr_display_contents;
 }

 function cr_make_btn_long_label(role_id, size)
 {
    let label = credit_roles[role_id];
    if (size != '_')
    {
      label += " (" + credit_sizes_long[size] + ")";
    }
    return label;
 }