<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ExperiencePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ExperiencePanel" %>

<div class="admin-panel" data-panel="experience">
    <h2>Experience</h2>
    <p class="admin-sub">Professional roles and positions. Tags can be added interactively.</p>

    <div class="add-form">
        <div class="field field-col-3"><label>Role</label><div class="input-row"><input type="text" placeholder="Front-End Developer" /></div></div>
        <div class="field field-col-3"><label>Company</label><div class="input-row"><input type="text" placeholder="Company / Organization" /></div></div>
        <div class="field field-col-3">
            <label>Period (Date Range)</label>
            <div class="input-date-wrap">
                <input type="text" class="date-range-picker" placeholder="Select Period Range..." />
                <svg class="input-date-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
            </div>
        </div>
        <div class="field field-col-2">
            <label>Tags </label>
            <div class="chips-container" id="expTagChips" data-input-target="hidExpTags">
                <div class="chips-list">
                    <span class="chip-tag"><span>React</span><span class="chip-remove" title="Remove">&times;</span></span>
                    <span class="chip-tag"><span>Tailwind CSS</span><span class="chip-remove" title="Remove">&times;</span></span>
                </div>
                <input type="text" class="chip-input" placeholder="Type tag & hit Enter..." />
            </div>
            <input type="hidden" id="hidExpTags" value="React,Tailwind CSS" />
        </div>
        <div class="field field-col-2">
            <label>Description</label>
            <textarea rows="3" placeholder="Describe responsibilities and impact..."></textarea>
        </div>
        <div style="grid-column: 1 / -1;">
            <button type="button" class="btn btn-primary">Add Experience</button>
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Role</th><th>Company</th><th>Period</th><th>Description</th><th>Tags</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>Front-End Developer</td><td>Prince IT Solution</td><td>AUG 2025 — NOV 2025</td>
                    <td>Design and develop responsive web interfaces using React and Tailwind.</td>
                    <td>React, Tailwind CSS</td>
                    <td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td>
                </tr>
                <tr>
                    <td>Full-Stack Developer</td><td>Teranet Fiber, Q.C.</td><td>MAR 2024 — APR 2024</td>
                    <td>Assisted in basic web development, backend tasks, and system support.</td>
                    <td>Web Development, Backend Tasks</td>
                    <td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
