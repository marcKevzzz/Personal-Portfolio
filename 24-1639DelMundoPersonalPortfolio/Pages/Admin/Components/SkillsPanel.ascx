<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SkillsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.SkillsPanel" %>

<div class="admin-panel" data-panel="skills">
    <h2>Skills</h2>
    <p class="admin-sub">Segments range from 0–8, displayed as stepped signal bars on the landing page.</p>

    <div class="add-form">
        <div class="field"><label>Skill name</label><input type="text" placeholder="Frontend Development" /></div>
        <div class="field"><label>Level</label><input type="text" placeholder="ADVANCED" /></div>
        <div class="field"><label>Segments (0-8)</label><input type="text" placeholder="7" /></div>
        <div class="field"><label>Context</label><input type="text" placeholder="Applied in..." /></div>
        <button type="button" class="btn btn-primary">Add Skill</button>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Skill</th><th>Level</th><th>Segments</th><th>Context</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr><td>Frontend Development</td><td>ADVANCED</td><td>7</td><td>Production web apps</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>Data Structuring</td><td>ADVANCED</td><td>7</td><td>JSON &amp; Relational datasets</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>3D Web Integration</td><td>PROFICIENT</td><td>6</td><td>Three.js scene pipelines</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
