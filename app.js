const $=s=>document.querySelector(s);const $$=s=>document.querySelectorAll(s);
const seed={projects:[{name:"My Cloud Studio",type:"Backend platform",status:"In development"},{name:"Demo Store",type:"E-commerce website",status:"Planning"}],tables:[{name:"customers",kind:"SQL table",fields:"id · name · email · created_at"},{name:"orders",kind:"SQL table",fields:"id · customer_id · total · status"},{name:"site_settings",kind:"JSON collection",fields:"theme · contact · preferences"}],apis:[["GET","/api/projects","List projects"],["POST","/api/orders","Create an order"],["GET","/api/orders/:id","Read an order"],["PATCH","/api/orders/:id","Update an order"]],files:[["/uploads/","Folder","R2 planned"],["/exports/orders.json","JSON","R2 planned"],["/images/logo.png","Image","R2 planned"]],users:[["admin@example.test","Owner"],["manager@example.test","Manager"]],connections:[["Demo Store","https://example.com","Pending setup"],["Portfolio demo","https://example.org","Pending setup"]],logs:["Workspace prototype opened","Sample project data loaded","Demo schema displayed"]};
let data;try{data=JSON.parse(localStorage.getItem("dvcDistrack"))||seed}catch{data=seed}
function save(){localStorage.setItem("dvcDistrack",JSON.stringify(data));render()}
function rows(items,render){return items.map(render).join("")}
function render(){ $("#project-count").textContent=data.projects.length;$("#table-count").textContent=data.tables.length;
$("#project-list").innerHTML=rows(data.projects,x=>`<article class="project-card"><h3>${esc(x.name)}</h3><small>${esc(x.status)}</small><p>${esc(x.type)}</p></article>`);
$("#table-list").innerHTML=rows(data.tables,x=>`<div class="data-row"><div><b>${esc(x.name)}</b><small>${esc(x.fields)}</small></div><span class="pill">${esc(x.kind)}</span></div>`);
$("#api-list").innerHTML=rows(data.apis,x=>`<div class="data-row"><div><b>${esc(x[0])} &nbsp; ${esc(x[1])}</b><small>${esc(x[2])}</small></div><span class="pill">Planned</span></div>`);
$("#file-list").innerHTML=rows(data.files,x=>`<div class="data-row"><div><b>${esc(x[0])}</b><small>${esc(x[1])}</small></div><span class="pill">${esc(x[2])}</span></div>`);
$("#user-list").innerHTML=rows(data.users,x=>`<div class="data-row"><b>${esc(x[0])}</b><span class="pill">${esc(x[1])}</span></div>`);
$("#connection-list").innerHTML=rows(data.connections,x=>`<article class="project-card"><h3>${esc(x[0])}</h3><p>${esc(x[1])}</p><small>${esc(x[2])}</small></article>`);
$("#log-list").innerHTML=rows(data.logs.slice().reverse(),x=>`<div class="data-row"><div>${esc(x)}<small>Browser prototype event</small></div><span class="pill">Local</span></div>`);
}
function esc(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
function go(id){$$(".page").forEach(p=>p.classList.toggle("active",p.id===id));$$(".nav").forEach(n=>n.classList.toggle("active",n.dataset.page===id));$("#page-title").textContent=id==="api"?"API manager":id==="users"?"User authentication":id==="connections"?"Website connections":id==="logs"?"Activity logs":id==="database"?"Database builder":id[0].toUpperCase()+id.slice(1);window.scrollTo(0,0)}
$$(".nav").forEach(n=>n.addEventListener("click",()=>go(n.dataset.page)));$$("[data-go]").forEach(n=>n.addEventListener("click",()=>go(n.dataset.go)));
$("#add-project").onclick=()=>{let name=prompt("Project name?");if(name){data.projects.push({name,type:"New project",status:"Planning"});data.logs.push("Added project "+name);save()}};
$("#add-table").onclick=()=>{let name=prompt("Table or collection name?");if(name){let fields=prompt("Field names, separated by commas:","id, name, created_at")||"id";data.tables.push({name,kind:"SQL table",fields:fields.split(",").map(x=>x.trim()).join(" · ")});data.logs.push("Added schema preview "+name);save()}};
$("#add-api").onclick=()=>{let path=prompt("Endpoint path, e.g. /api/items");if(path){data.apis.push(["GET",path,"New endpoint draft"]);data.logs.push("Added endpoint draft "+path);save()}};
$("#add-file").onclick=()=>{let path=prompt("Sample object path:","/uploads/new-file.json");if(path){data.files.push([path,"Object","R2 planned"]);data.logs.push("Added file placeholder "+path);save()}};
$("#add-user").onclick=()=>{let email=prompt("Demo email address:");if(email){data.users.push([email,"Viewer"]);data.logs.push("Added demo user "+email);save()}};
$("#add-connection").onclick=()=>{let name=prompt("Website name:");if(name){let url=prompt("Website URL:","https://");data.connections.push([name,url||"Not supplied","Pending setup"]);data.logs.push("Added website connection "+name);save()}};
$("#save-settings").onclick=()=>{data.logs.push("Workspace name saved locally");save();alert("Saved in this browser only.")};
render();
