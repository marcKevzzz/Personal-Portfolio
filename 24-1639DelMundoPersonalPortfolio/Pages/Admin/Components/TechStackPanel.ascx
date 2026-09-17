<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TechStackPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.TechStackPanel" %>

<div class="admin-panel" data-panel="techstack">
    <h2>Tech Stack</h2>
    <p class="admin-sub">Grouped by category — items with the same group render together on the public page.</p>

    <div class="add-form">
        <div class="field"><label>Group</label><div class="input-row"><input type="text" placeholder="Frontend" /></div></div>
        <div class="field"><label>Label</label><div class="input-row"><input type="text" placeholder="HTML5" /></div></div>
        <div class="field"><label>Icon path</label><div class="input-row"><input type="text" placeholder="Assets/Icons/html5.svg" /></div></div>
        <button type="button" class="btn btn-primary">Add Tech Item</button>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Group</th><th>Label</th><th>Icon path</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr><td>Frontend</td><td>HTML5</td><td>Assets/Icons/html5.svg</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>Frontend</td><td>CSS3</td><td>Assets/Icons/css3.svg</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>3D &amp; Motion</td><td>GSAP</td><td>Assets/Icons/gsap.svg</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>Backend &amp; Database</td><td>C#</td><td>Assets/Icons/csharp.svg</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
