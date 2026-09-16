<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AwardsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AwardsPanel" %>

<div class="admin-panel" data-panel="awards">
    <h2>Awards &amp; Recognitions</h2>
    <p class="admin-sub">Competitions, certificates, and milestones.</p>

    <div class="add-form">
        <div class="field">
            <label>Year / Date</label>
            <div class="input-date-wrap">
                <input type="text" class="date-picker" placeholder="Select Year / Date..." />
                <svg class="input-date-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
            </div>
        </div>
        <div class="field"><label>Title</label><input type="text" placeholder="DevCup 2026" /></div>
        <div class="field"><label>Subtitle</label><input type="text" placeholder="2nd Place QCU" /></div>
        <div class="field"><label>Organization</label><input type="text" placeholder="Quezon City University" /></div>
        <button type="button" class="btn btn-primary">Add Award</button>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Year / Date</th><th>Title</th><th>Subtitle</th><th>Organization</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr><td>2026</td><td>DevCup 2026 Competition</td><td>2nd Place QCU</td><td>Quezon City University</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>2025</td><td>Code Quest 2025</td><td>Certificate of Participation</td><td>Quezon City University</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
