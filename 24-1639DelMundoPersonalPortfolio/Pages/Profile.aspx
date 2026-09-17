<%@ Page Title="Account Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
  CodeBehind="Profile.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.AccountProfile" %>
  <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  </asp:Content>
  <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="account-page-container wrap-wide">
      <!-- Left Sidebar / Header Section -->
      <aside class="account-top-bar">
        <div class="account-top-bar-header">
          <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-portfolio-link">&larr; Back to Portfolio</a>
          <div class="account-title-group">
            <div class="field-label">ACCOUNT / SETTINGS</div>
            <h1 class="account-page-title">Profile Settings</h1>
          </div>
        </div>

        <div class="account-avatar-wrapper">
          <div class="avatar-preview-container">
            <asp:Image ID="imgAvatarPreview" runat="server" ClientIDMode="Static" CssClass="account-avatar-img" alt="Profile Avatar" />
            <label for="avatarUpload" class="avatar-edit-overlay" title="Change Avatar">
              <svg class="camera-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                <circle cx="12" cy="13" r="4"></circle>
              </svg>
              <span>Change Photo</span>
            </label>
            <asp:FileUpload ID="avatarUpload" runat="server" ClientIDMode="Static" accept="image/png,image/jpeg,image/webp,image/gif" style="display:none;" />
          </div>
          <div class="avatar-info">
            <h3 id="profileHeaderName"><asp:Literal ID="litProfileHeaderName" runat="server" /></h3>
            <div class="account-badge-group">
              <span class="account-badge"><span class="status-dot"></span><asp:Literal ID="litStatusText" runat="server" Text="Active Account" /></span>
            </div>
            <div class="meta-item">
            <span class="meta-label">Member Since</span>
            <span class="meta-value"><asp:Literal ID="litMemberSince" runat="server" /></span>
          </div>
          </div>
        </div>

        <!-- Admin Portal Quick Nav Link (for admins) -->
        <asp:PlaceHolder ID="phAdminLink" runat="server" Visible="false">
          <div style="margin-top: 16px;">
            <a href="<%= ResolveUrl("~/Pages/Admin/Admin.aspx") %>" class="submit" style="display: flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; padding: 10px; font-size: 13px;">
              <span>Go to Admin Portal &rarr;</span>
            </a>
          </div>
        </asp:PlaceHolder>

        <!-- Sign Out Button -->
        <div class="signout-section">
          <button type="button" class="signout-btn" id="signoutBtn" title="Sign out of your session">
            <svg class="signout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
              <polyline points="16 17 21 12 16 7"></polyline>
              <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      <!-- Main Account Form Area -->
      <main class="account-card">

        <!-- In-card Notification Alert -->
        <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="save-toast" style="margin-bottom: 24px;">
          <asp:Literal ID="litAlertIcon" runat="server" />
          <asp:Literal ID="litAlertMsg" runat="server" />
        </asp:Panel>

        <!-- Account Form -->
        <div id="profileForm" novalidate>

          <!-- Section 1: Personal Information -->
          <div class="form-section">
            <div class="section-header">
              <h3 class="section-title">Personal Information</h3>
            </div>

            <div class="form-grid-2col">
              <!-- Col 1: First Name -->
              <div class="field" id="fieldFirstName">
                <label for="txtFirstName">FIRST NAME</label>
                <div class="input-row">
                  <asp:TextBox ID="txtFirstName" runat="server" ClientIDMode="Static" placeholder="First Name" />
                </div>
                <div class="field-error">Enter your first name.</div>
              </div>

              <!-- Col 2: Last Name -->
              <div class="field" id="fieldLastName">
                <label for="txtLastName">LAST NAME</label>
                <div class="input-row">
                  <asp:TextBox ID="txtLastName" runat="server" ClientIDMode="Static" placeholder="Last Name" />
                </div>
                <div class="field-error">Enter your last name.</div>
              </div>
            </div>

            <div class="form-grid-2col" style="margin-top: 16px;">
              <!-- Col 1: Email -->
              <div class="field">
                <label for="txtEmail">EMAIL ADDRESS</label>
                <div class="input-row">
                  <asp:TextBox ID="txtEmail" runat="server" ClientIDMode="Static" TextMode="Email" ReadOnly="true" style="opacity: 0.75; cursor: not-allowed;" />
                </div>
                <div class="field-error">Registered email is linked to account authentication.</div>
              </div>

              <!-- Col 2: Role Info -->
              <div class="field">
                <label for="txtRole">ACCOUNT ROLE</label>
                <div class="input-row">
                  <asp:TextBox ID="txtRole" runat="server" ClientIDMode="Static" ReadOnly="true" style="opacity: 0.75; cursor: not-allowed;" />
                </div>
              </div>
            </div>
          </div>

          <div class="section-divider"></div>

          <!-- Section 2: Security & Credentials -->
          <div class="form-section">
            <div class="section-header">
              <h3 class="section-title">Security & Credentials</h3>
              <p class="section-desc">Leave password fields blank if you do not wish to change your password.</p>
            </div>

            <div class="form-grid-2col">
              <!-- Col 1: Password -->
              <div class="field" id="fieldNewPassword">
                <label for="txtNewPassword">NEW PASSWORD</label>
                <div class="input-row">
                  <asp:TextBox ID="txtNewPassword" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                </div>
                <div class="strength" id="strengthMeter" data-level="0">
                  <i></i><i></i><i></i>
                </div>
                <div class="field-error">Password must be at least 8 characters.</div>
              </div>

              <!-- Col 2: Confirm password -->
              <div class="field" id="fieldConfirmPassword">
                <label for="txtConfirmPassword">CONFIRM NEW PASSWORD</label>
                <div class="input-row">
                  <asp:TextBox ID="txtConfirmPassword" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                </div>
                <div class="field-error">Passwords don't match.</div>
              </div>
            </div>
          </div>

          <!-- Section 3: Admin Security Queue - Password Removal Requests (Visible only for Admin role) -->
          <asp:Panel ID="adminQueueSection" runat="server" Visible="false" CssClass="form-section">
            <div class="section-divider"></div>
            <div class="section-header">
              <div class="field-label" style="color: var(--cyan); margin-bottom: 4px;">ADMIN PRIVILEGE / SECURITY QUEUE</div>
              <h3 class="section-title">Password Removal Requests</h3>
              <p class="section-desc">Manage user requests to clear account passwords. When removed, the user receives authorization to create a new password.</p>
            </div>

            <div class="admin-requests-container">
              <asp:Repeater ID="rptAdminRequests" runat="server" OnItemCommand="rptAdminRequests_ItemCommand">
                <ItemTemplate>
                  <div class="admin-req-card" style="display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border: 1px solid var(--line); margin-bottom: 10px; background: rgba(255,255,255,0.02);">
                    <div class="admin-req-info">
                      <div class="admin-req-email" style="font-weight: 600; color: var(--text);"><%# Eval("email") %></div>
                      <div class="admin-req-meta" style="font-size: 12px; color: var(--text-dim); margin-top: 4px;">
                        Requested: <%# Eval("created_at", "{0:MMM dd, yyyy HH:mm}") %> &bull; Reason: <%# Eval("reason") %>
                      </div>
                    </div>
                    <div class="admin-req-actions">
                      <asp:Button ID="btnApproveRemoval" runat="server" CommandName="RemovePassword" CommandArgument='<%# Eval("reset_id") %>' Text="Remove Password" CssClass="admin-action-remove-btn" style="background: rgba(255, 77, 79, 0.15); border: 1px solid #ff4d4f; color: #ff4d4f; padding: 6px 14px; font-size: 12px; font-family: var(--f-sans); font-weight: 600; cursor: pointer; transition: background 0.2s;" />
                    </div>
                  </div>
                </ItemTemplate>
                <FooterTemplate>
                  <asp:Literal ID="litEmptyMsg" runat="server" Text='<div class="empty-requests-msg"><span class="pulse-indicator"></span><span>No pending password removal requests at this time.</span></div>' Visible='<%# rptAdminRequests.Items.Count == 0 %>' />
                </FooterTemplate>
              </asp:Repeater>
            </div>
          </asp:Panel>

          <!-- Save Button Actions -->
          <div class="account-form-actions">
            <button type="button" id="btnTriggerSave" class="submit account-submit-btn">Save Changes</button>
            <asp:Button ID="btnSaveProfile" runat="server" ClientIDMode="Static" style="display:none;" OnClick="btnSaveProfile_Click" />
          </div>

        </div>

      </main>

    </div>

    <!-- Logout Confirmation Modal -->
    <div id="logoutConfirmModal" class="modal-backdrop" style="display: none;">
      <div class="modal-dialog" style="max-width: 440px;">
        <div class="modal-header">
          <div>
            <div class="modal-kicker">SESSION TERMINATION</div>
            <h3 class="modal-title">Confirm Sign Out</h3>
          </div>
          <button type="button" class="modal-close-btn" data-close-modal="#logoutConfirmModal">&times;</button>
        </div>
        <div class="modal-body-instruction" style="margin: 20px 0 24px; font-size: var(--t-sm); color: var(--text-mid); line-height: 1.5;">
          Are you sure you want to end your current session and sign out? You will need to sign in again to access your account.
        </div>
        <div class="modal-footer">
          <button type="button" class="modal-btn-cancel" data-close-modal="#logoutConfirmModal">Cancel</button>
          <a href="<%= ResolveUrl("~/Auth/SignIn.aspx?logout=true") %>" class="modal-btn-danger" id="btnConfirmSignOut">
            <span>Sign Out</span>
          </a>
        </div>
      </div>
    </div>

    <!-- Save Changes Confirmation Modal -->
    <div id="saveConfirmModal" class="modal-backdrop" style="display: none;">
      <div class="modal-dialog" style="max-width: 460px;">
        <div class="modal-header">
          <div>
            <div class="modal-kicker">PROFILE UPDATE</div>
            <h3 class="modal-title">Save Profile Changes</h3>
          </div>
          <button type="button" class="modal-close-btn" data-close-modal="#saveConfirmModal">&times;</button>
        </div>
        <div class="modal-body-instruction" style="margin: 20px 0 24px; font-size: var(--t-sm); color: var(--text-mid); line-height: 1.5;">
          Are you sure you want to apply these changes to your profile and security credentials?
        </div>
        <div class="modal-footer">
          <button type="button" class="modal-btn-cancel" data-close-modal="#saveConfirmModal">Cancel</button>
          <button type="button" class="submit modal-btn-accept" id="btnConfirmSave">
            <span>Confirm & Save</span>
          </button>
        </div>
      </div>
    </div>

    <script>
      document.addEventListener("DOMContentLoaded", function () {
        // 1. Instant Client-side Image Preview
        var fileInput = document.getElementById("avatarUpload");
        var previewImg = document.getElementById("imgAvatarPreview");
        if (fileInput && previewImg) {
          fileInput.addEventListener("change", function () {
            var file = fileInput.files && fileInput.files[0];
            if (file) {
              var reader = new FileReader();
              reader.onload = function (e) {
                previewImg.src = e.target.result;
              };
              reader.readAsDataURL(file);
            }
          });
        }

        // 2. Modal Utilities
        function openModal(modalId) {
          var modal = document.querySelector(modalId);
          if (modal) {
            modal.style.display = "flex";
            document.body.style.overflow = "hidden";
          }
        }

        function closeModal(modalId) {
          var modal = document.querySelector(modalId);
          if (modal) {
            modal.style.display = "none";
            document.body.style.overflow = "";
          }
        }

        // Close handlers
        document.querySelectorAll("[data-close-modal]").forEach(function (btn) {
          btn.addEventListener("click", function () {
            var target = this.getAttribute("data-close-modal");
            closeModal(target);
          });
        });

        // Close when clicking outside dialog
        document.querySelectorAll(".modal-backdrop").forEach(function (backdrop) {
          backdrop.addEventListener("click", function (e) {
            if (e.target === backdrop) {
              backdrop.style.display = "none";
              document.body.style.overflow = "";
            }
          });
        });

        // Close on Escape key
        document.addEventListener("keydown", function (e) {
          if (e.key === "Escape") {
            document.querySelectorAll(".modal-backdrop").forEach(function (modal) {
              modal.style.display = "none";
            });
            document.body.style.overflow = "";
          }
        });

        // 3. Logout Confirmation Hook
        var signoutBtn = document.getElementById("signoutBtn");
        if (signoutBtn) {
          signoutBtn.addEventListener("click", function (e) {
            e.preventDefault();
            openModal("#logoutConfirmModal");
          });
        }

        // 4. Save Profile Trigger & Validation Hook
        var btnTriggerSave = document.getElementById("btnTriggerSave");
        var btnSaveReal = document.getElementById("btnSaveProfile");
        var txtFirst = document.getElementById("txtFirstName");
        var txtLast = document.getElementById("txtLastName");
        var txtNewPass = document.getElementById("txtNewPassword");
        var txtConfPass = document.getElementById("txtConfirmPassword");

        if (btnTriggerSave && btnSaveReal) {
          btnTriggerSave.addEventListener("click", function (e) {
            e.preventDefault();

            // Client-side field validation
            var hasError = false;

            var fFirst = document.getElementById("fieldFirstName");
            var fLast = document.getElementById("fieldLastName");
            var fNewP = document.getElementById("fieldNewPassword");
            var fConfP = document.getElementById("fieldConfirmPassword");

            if (fFirst) fFirst.classList.remove("invalid");
            if (fLast) fLast.classList.remove("invalid");
            if (fNewP) fNewP.classList.remove("invalid");
            if (fConfP) fConfP.classList.remove("invalid");

            if (!txtFirst || !txtFirst.value.trim()) {
              if (fFirst) fFirst.classList.add("invalid");
              hasError = true;
            }
            if (!txtLast || !txtLast.value.trim()) {
              if (fLast) fLast.classList.add("invalid");
              hasError = true;
            }

            var newP = txtNewPass ? txtNewPass.value.trim() : "";
            var confP = txtConfPass ? txtConfPass.value.trim() : "";

            if (newP.length > 0) {
              if (newP.length < 8) {
                if (fNewP) fNewP.classList.add("invalid");
                hasError = true;
              }
              if (newP !== confP) {
                if (fConfP) fConfP.classList.add("invalid");
                hasError = true;
              }
            }

            if (hasError) return;

            // Open Confirmation Modal
            openModal("#saveConfirmModal");
          });

          // Inside Confirmation Modal: Confirm & Save Click
          var btnConfirmSave = document.getElementById("btnConfirmSave");
          if (btnConfirmSave) {
            btnConfirmSave.addEventListener("click", function () {
              closeModal("#saveConfirmModal");
              btnSaveReal.click();
            });
          }
        }
      });
    </script>
  </asp:Content>