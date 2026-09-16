<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProfilePanel" %>

<div class="admin-panel active" data-panel="profile">
    <h2>Public Profile &amp; Hero</h2>
    <p class="admin-sub">Configure hero heading, basic personal information, and social links for the public portfolio page.</p>

    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero kicker</label>
            <div class="input-row"><input type="text" value="PERSONAL PORTFOLIO" /></div>
        </div>
        <div class="field">
            <label>Hero subline</label>
            <div class="input-row"><input type="text" value="/ builds interfaces" /></div>
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero names / aliases (Hit Enter or comma to add)</label>
            <div class="chips-container" id="heroNameChips" data-input-target="hidHeroNames">
                <div class="chips-list">
                    <span class="chip-tag"><span>Kevs</span><span class="chip-remove" title="Remove">&times;</span></span>
                    <span class="chip-tag"><span>Marc Kevin</span><span class="chip-remove" title="Remove">&times;</span></span>
                    <span class="chip-tag"><span>Software Engineer</span><span class="chip-remove" title="Remove">&times;</span></span>
                </div>
                <input type="text" class="chip-input" placeholder="Type name & hit Enter..." />
            </div>
            <input type="hidden" id="hidHeroNames" value="Kevs,Marc Kevin,Software Engineer" />
        </div>
        <div class="field">
            <label>Role summary paragraph</label>
            <textarea class="hero-txtarea" rows="3">Web developer working across front-end interfaces and the structured data systems behind them — from motion-driven product pages to large-scale JSON datasets.</textarea>
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Role</label>
            <div class="input-row"><input type="text" value="Web Developer" /></div>
        </div>
        <div class="field">
            <label>Focus</label>
            <div class="input-row"><input type="text" value="Interfaces & Data Systems" /></div>
        </div>
        <div class="field">
            <label>Based in</label>
            <div class="input-row"><input type="text" value="Quezon City" /></div>
        </div>
        <div class="field">
            <label>Avatar image path</label>
            <div class="input-row"><input type="text" value="Assets/Images/pixelart_portrait.png" /></div>
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Full name</label>
            <div class="input-row"><input type="text" value="Del Mundo, Marc Kevin F." /></div>
        </div>
        <div class="field">
            <label>Location</label>
            <div class="input-row"><input type="text" value="B2 L6 Emerald St. Novaliches Proper, Q.C." /></div>
        </div>
        <div class="field">
            <label>Age</label>
            <div class="input-row"><input type="text" value="19 years old" /></div>
        </div>
        <div class="field">
            <label>Experience</label>
            <div class="input-row"><input type="text" value="3 years of coding" /></div>
        </div>
    </div>
    <div class="admin-fieldgroup three-col">
        <div class="field">
            <label>Email</label>
            <div class="input-row"><input type="text" value="delmundo.marckevin.ferolino@gmail.com" /></div>
        </div>
        <div class="field">
            <label>GitHub URL</label>
            <div class="input-row"><input type="text" value="https://github.com/marcKevzzz" /></div>
        </div>
        <div class="field">
            <label>LinkedIn URL</label>
            <div class="input-row"><input type="text" value="https://linkedin.com/in/..." /></div>
        </div>
    </div>

    <button type="button" id="btnSaveProfile" class="btn btn-primary">Save Profile Settings</button>
</div>
