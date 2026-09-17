<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.HobbiesPanel" %>

<div class="admin-panel" data-panel="hobbies">
    <h2>Hobbies</h2>
    <p class="admin-sub">Personal interests displayed in chips on the portfolio page.</p>

    <div class="add-form">
        <div class="field"><label>New hobby</label><div class="input-row"><input type="text" placeholder="Basketball" /></div></div>
        <button type="button" class="btn btn-primary">Add Hobby</button>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Hobby</th><th>Action</th></tr>
            </thead>
            <tbody>
                <tr><td>Reading Manhwa, Manhua &amp; Manga</td><td><a href="javascript:void(0)" class="danger">Remove</a></td></tr>
                <tr><td>Online Games</td><td><a href="javascript:void(0)" class="danger">Remove</a></td></tr>
                <tr><td>Coding</td><td><a href="javascript:void(0)" class="danger">Remove</a></td></tr>
                <tr><td>Basketball</td><td><a href="javascript:void(0)" class="danger">Remove</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
