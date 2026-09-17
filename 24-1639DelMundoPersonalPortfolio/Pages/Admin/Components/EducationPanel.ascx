<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.EducationPanel" %>

<div class="admin-panel" data-panel="education">
    <h2>Education</h2>
    <p class="admin-sub">Academic degrees and qualifications.</p>

    <div class="add-form">
        <div class="field">
            <label>Year / Period (Date Range)</label>
            <div class="input-date-wrap">
                <input type="text" class="date-range-picker" placeholder="Select Year / Period..." />
                <svg class="input-date-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
            </div>
        </div>
        <div class="field"><label>Title</label><div class="input-row"><input type="text" placeholder="Collegiate Level" /></div></div>
        <div class="field"><label>Subtitle</label><div class="input-row"><input type="text" placeholder="B.S. Information Technology" /></div></div>
        <div class="field"><label>Organization</label><div class="input-row"><input type="text" placeholder="Quezon City University" /></div></div>
        <button type="button" class="btn btn-primary">Add Education</button>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Year / Period</th><th>Title</th><th>Subtitle</th><th>Organization</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr><td>2024 — Present</td><td>Collegiate Level</td><td>B.S. Information Technology</td><td>Quezon City University</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
                <tr><td>June 2024</td><td>Senior High School</td><td>ICT</td><td>Gardner College Diliman</td><td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td></tr>
            </tbody>
        </table>
    </div>
</div>
