<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProjectsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProjectsPanel" %>

<div class="admin-panel" data-panel="projects">
    <h2>Projects</h2>
    <p class="admin-sub">Manage portfolio showcase projects and technology tags.</p>

    <div class="add-form">
        <div class="field"><label>Project Title</label><div class="input-row"><input type="text" placeholder="e.g. Samson Dental Center" /></div></div>
        <div class="field"><label>Image path</label><div class="input-row"><input type="text" placeholder="Assets/Images/samsondentalcenter.png" /></div></div>
        <div class="field"><label>Project URL / Repo</label><div class="input-row"><input type="text" placeholder="https://github.com/..." /></div></div>
        <div class="field" style="grid-column: 1 / -1;">
            <label>Tags </label>
            <div class="chips-container" id="projectTagChips" data-input-target="hidProjectTags">
                <div class="chips-list">
                    <span class="chip-tag"><span>HTML5</span><span class="chip-remove" title="Remove">&times;</span></span>
                    <span class="chip-tag"><span>CSS3</span><span class="chip-remove" title="Remove">&times;</span></span>
                    <span class="chip-tag"><span>JavaScript</span><span class="chip-remove" title="Remove">&times;</span></span>
                </div>
                <input type="text" class="chip-input" placeholder="Type tag & hit Enter..." />
            </div>
            <input type="hidden" id="hidProjectTags" value="HTML5,CSS3,JavaScript" />
        </div>
        <div style="grid-column: 1 / -1;">
            <button type="button" class="btn btn-primary">Add Project</button>
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Title</th><th>Image</th><th>Tags</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr><td>Samson Dental Center</td><td>Assets/Images/samsondentalcenter.png</td><td>HTML5, CSS3, JavaScript</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>Review Bot Assistant</td><td>Assets/Images/reviewbot.png</td><td>Chatbot AI, DOM Scripting</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
