/* =============================================================
   ADMIN PANEL SCRIPT
   Dedicated GSAP-enhanced logic for Pages/Admin/Admin.aspx
   ============================================================= */

document.addEventListener("DOMContentLoaded", function () {
  AdminModal.init();
  initAdminCursor();
  initAdminSidebarAnimations();
  initAdminNavigation();
  initInputChips();
  initAdminDatePickers();
  initAdminAvatarUpload();
  initAdminProfile();
  initSaveProfile();
  initAdminLogout();
  initTableActions();
  initAddFormActions();
});

/* -------------------------------------------------------------
   CUSTOM INVERTING CURSOR (ADMIN)
   ------------------------------------------------------------- */
function initAdminCursor() {
  if (!window.matchMedia("(pointer: fine)").matches) return;

  var cursor = document.getElementById("customCursor");
  if (!cursor) {
    cursor = document.createElement("div");
    cursor.className = "custom-cursor";
    cursor.id = "customCursor";
    var circle = document.createElement("div");
    circle.className = "custom-cursor-circle";
    cursor.appendChild(circle);
    document.body.appendChild(cursor);
  }

  var dot = cursor.querySelector(".custom-cursor-circle");
  var isMoved = false;
  var isHovered = false;

  if (typeof gsap !== "undefined" && dot) {
    gsap.set(dot, { xPercent: -50, yPercent: -50 });
  }

  window.addEventListener("mousemove", function (e) {
    if (!isMoved) {
      cursor.classList.add("is-visible");
      isMoved = true;
    }
    cursor.style.transform =
      "translate(" + e.clientX + "px, " + e.clientY + "px)";
  });

  document.addEventListener("mouseleave", function () {
    cursor.classList.remove("is-visible");
  });

  document.addEventListener("mouseenter", function () {
    if (isMoved) cursor.classList.add("is-visible");
  });

  // Subtle click animation
  window.addEventListener("mousedown", function () {
    if (typeof gsap !== "undefined" && dot) {
      gsap.to(dot, {
        scale: isHovered ? 1.15 : 0.85,
        duration: 0.15,
        ease: "power2.out",
      });
    }
  });

  window.addEventListener("mouseup", function () {
    if (typeof gsap !== "undefined" && dot) {
      gsap.to(dot, {
        scale: isHovered ? 1.15 : 1,
        duration: 0.18,
        ease: "power2.out",
      });
    }
  });

  // Magnetic scale on hover targets (reduced to subtle 1.35x)
  if (typeof gsap !== "undefined" && dot) {
    var hoverTargets = document.querySelectorAll(
      "a, button, input, textarea, select, .nav-item, .btn, .sidebar-toggle-btn, .admin-logout-btn, .admin-avatar-box, .status-pill, .chip, .chip-tag, .chip-remove, .chip-input, .chips-container, .data-table tr",
    );
    hoverTargets.forEach(function (target) {
      target.addEventListener("mouseenter", function () {
        isHovered = true;
        gsap.to(dot, { scale: 1.15, duration: 0.2, ease: "power2.out" });
      });
      target.addEventListener("mouseleave", function () {
        isHovered = false;
        gsap.to(dot, { scale: 1, duration: 0.2, ease: "power2.out" });
      });
    });
  }
}

/* -------------------------------------------------------------
   GSAP SIDEBAR COLLAPSIBLE OPEN / CLOSE LOGIC
   ------------------------------------------------------------- */
function initAdminSidebarAnimations() {
  var shell = document.getElementById("adminShell");
  var nav = document.getElementById("adminNav");
  var toggleBtn = document.getElementById("btnToggleSidebar");
  if (!shell || !nav || !toggleBtn) return;

  var toggleIcon = toggleBtn.querySelector("svg");
  var brand = nav.querySelector(".admin-brand");
  var navLabels = nav.querySelectorAll(".nav-label");
  var logoutText = nav.querySelector(".logout-text");

  var isCollapsed = localStorage.getItem("admin_sidebar_collapsed") === "true";

  function setSidebarState(collapsed, animate) {
    var targetWidth = collapsed ? 68 : 240;

    if (collapsed) {
      shell.classList.add("sidebar-collapsed");
    } else {
      shell.classList.remove("sidebar-collapsed");
    }

    if (animate && typeof gsap !== "undefined") {
      var tl = gsap.timeline({ defaults: { ease: "power2.inOut" } });

      // Animate sidebar width smoothly with GSAP
      tl.to(nav, { width: targetWidth, duration: 0.3 }, 0);

      // Rotate toggle icon chevron
      if (toggleIcon) {
        tl.to(toggleIcon, { rotate: collapsed ? 180 : 0, duration: 0.3 }, 0);
      }

      if (collapsed) {
        // Fade out brand (dot + title) and labels
        tl.to(
          [brand, navLabels, logoutText],
          {
            opacity: 0,
            duration: 0.16,
          },
          0,
        );
      } else {
        // Fade in brand and labels
        tl.to(
          [brand, navLabels, logoutText],
          {
            opacity: 1,
            duration: 0.22,
            delay: 0.08,
          },
          0,
        );
      }
    } else {
      // Immediate load without animation
      if (typeof gsap !== "undefined") {
        gsap.set(nav, { width: targetWidth });
        if (toggleIcon) gsap.set(toggleIcon, { rotate: collapsed ? 180 : 0 });
        gsap.set([brand, navLabels, logoutText], {
          opacity: collapsed ? 0 : 1,
        });
      } else {
        nav.style.width = targetWidth + "px";
        if (brand) brand.style.opacity = collapsed ? "0" : "1";
        navLabels.forEach(function (lbl) {
          lbl.style.opacity = collapsed ? "0" : "1";
        });
        if (logoutText) logoutText.style.opacity = collapsed ? "0" : "1";
      }
    }
  }

  // Initialize saved state
  setSidebarState(isCollapsed, false);

  toggleBtn.addEventListener("click", function () {
    isCollapsed = !isCollapsed;
    localStorage.setItem("admin_sidebar_collapsed", isCollapsed);
    setSidebarState(isCollapsed, true);
  });
}

/* -------------------------------------------------------------
   TAB PANEL NAVIGATION & GSAP TRANSITIONS
   ------------------------------------------------------------- */
function initAdminNavigation() {
  var navLinks = document.querySelectorAll(".admin-nav a[data-panel]");
  var panels = document.querySelectorAll(".admin-panel");
  var hidden = document.getElementById("hidActivePanel");
  var titleDisplay = document.getElementById("currentPanelTitle");

  function activatePanel(panelName) {
    if (!panelName) return;

    navLinks.forEach(function (a) {
      var match = a.getAttribute("data-panel") === panelName;
      a.classList.toggle("active", match);
    });

    panels.forEach(function (p) {
      var match = p.getAttribute("data-panel") === panelName;
      if (match) {
        p.classList.add("active");
        if (typeof gsap !== "undefined") {
          gsap.fromTo(
            p,
            { opacity: 0, y: 12 },
            { opacity: 1, y: 0, duration: 0.35, ease: "power2.out" },
          );
        }
      } else {
        p.classList.remove("active");
      }
    });

    if (hidden) {
      hidden.value = panelName;
    }

    // Update Topbar Title
    if (titleDisplay) {
      var activeLink = document.querySelector(
        '.admin-nav a[data-panel="' + panelName + '"] .nav-label',
      );
      if (activeLink) {
        titleDisplay.textContent = activeLink.textContent;
      }
    }

    localStorage.setItem("admin_active_panel", panelName);
  }

  navLinks.forEach(function (link) {
    link.addEventListener("click", function (e) {
      e.preventDefault();
      var target = link.getAttribute("data-panel");
      activatePanel(target);
    });
  });

  // Determine initial active panel
  var savedPanel = localStorage.getItem("admin_active_panel");
  var initial = hidden && hidden.value ? hidden.value : savedPanel || "profile";
  activatePanel(initial);
}

/* -------------------------------------------------------------
   INPUT CHIPS COMPONENT
   ------------------------------------------------------------- */
function initInputChips() {
  document.querySelectorAll(".chips-container").forEach(function (container) {
    var hiddenId = container.getAttribute("data-input-target");
    var hiddenInput = hiddenId ? document.getElementById(hiddenId) : null;
    var chipInput = container.querySelector(".chip-input");
    var chipsList = container.querySelector(".chips-list");

    if (!chipsList) {
      chipsList = document.createElement("div");
      chipsList.className = "chips-list";
      if (chipInput) {
        container.insertBefore(chipsList, chipInput);
      } else {
        container.appendChild(chipsList);
      }
    }

    function syncHidden() {
      if (!hiddenInput) return;
      var tags = [];
      chipsList.querySelectorAll(".chip-tag span:first-child").forEach(function (t) {
        tags.push(t.textContent.trim());
      });
      hiddenInput.value = tags.join(",");
    }

    function addChip(text) {
      var val = text.trim();
      if (!val) return;
      var tag = document.createElement("span");
      tag.className = "chip-tag";
      var span = document.createElement("span");
      span.textContent = val;
      var removeBtn = document.createElement("span");
      removeBtn.className = "chip-remove";
      removeBtn.title = "Remove";
      removeBtn.innerHTML = "&times;";
      tag.appendChild(span);
      tag.appendChild(removeBtn);

      chipsList.appendChild(tag);
      syncHidden();
    }

    container.addEventListener("click", function (e) {
      if (e.target && e.target.classList.contains("chip-remove")) {
        var tag = e.target.closest(".chip-tag");
        if (tag) {
          tag.remove();
          syncHidden();
        }
      } else if (chipInput && e.target !== chipInput) {
        chipInput.focus();
      }
    });

    if (chipInput) {
      chipInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter" || e.key === ",") {
          e.preventDefault();
          var val = chipInput.value.replace(/,/g, "").trim();
          if (val) {
            addChip(val);
            chipInput.value = "";
          }
        } else if (e.key === "Backspace" && chipInput.value === "") {
          var tags = chipsList.querySelectorAll(".chip-tag");
          if (tags.length > 0) {
            tags[tags.length - 1].remove();
            syncHidden();
          }
        }
      });

      chipInput.addEventListener("blur", function () {
        var val = chipInput.value.replace(/,/g, "").trim();
        if (val) {
          addChip(val);
          chipInput.value = "";
        }
      });
    }
  });
}

/* -------------------------------------------------------------
   CALENDAR & DATE PICKERS (FLATPICKR)
   ------------------------------------------------------------- */
function initAdminDatePickers() {
  if (typeof flatpickr === "undefined") return;

  flatpickr(".date-range-picker", {
    mode: "range",
    dateFormat: "Y-m-d",
    altInput: true,
    altFormat: "M Y",
    allowInput: true,
    theme: "dark",
  });

  flatpickr(".date-picker", {
    dateFormat: "Y",
    altInput: true,
    altFormat: "Y",
    allowInput: true,
    theme: "dark",
  });
}

/* -------------------------------------------------------------
   ADMIN AVATAR PREVIEW UPLOAD
   ------------------------------------------------------------- */
function initAdminAvatarUpload() {
  var uploadInput = document.getElementById("adminAvatarUpload");
  var previewImg = document.getElementById("adminAvatarPreview");
  if (!uploadInput || !previewImg) return;

  uploadInput.addEventListener("change", function (e) {
    var file = e.target.files && e.target.files[0];
    if (file) {
      var reader = new FileReader();
      reader.onload = function (evt) {
        previewImg.src = evt.target.result;
      };
      reader.readAsDataURL(file);
    }
  });
}

/* -------------------------------------------------------------
   ADMIN PROFILE & CREDENTIALS
   ------------------------------------------------------------- */
function initAdminProfile() {
  var pwInput = document.getElementById("adminNewPassword");
  var confirmInput = document.getElementById("adminConfirmPassword");
  var meter = document.getElementById("adminStrengthMeter");
  var saveBtn = document.getElementById("btnSaveAdminProfile");

  if (pwInput && meter) {
    pwInput.addEventListener("input", function () {
      var v = pwInput.value;
      var level = 0;
      if (v.length >= 8) level = 1;
      if (v.length >= 8 && /[0-9]/.test(v) && /[A-Z]/.test(v)) level = 2;
      if (
        v.length >= 12 &&
        /[0-9]/.test(v) &&
        /[A-Z]/.test(v) &&
        /[^A-Za-z0-9]/.test(v)
      )
        level = 3;
      meter.setAttribute("data-level", level);
    });
  }

  if (saveBtn) {
    saveBtn.addEventListener("click", function () {
      var newPw = pwInput ? pwInput.value : "";
      var confirmPw = confirmInput ? confirmInput.value : "";

      if (newPw) {
        if (newPw.length < 8) {
          AdminToast.warning("Password must be at least 8 characters.", "Security Warning");
          return;
        }
        if (newPw !== confirmPw) {
          AdminToast.error("Passwords do not match. Please verify your new password.", "Validation Error");
          return;
        }
      }

      AdminToast.success("Admin credentials and security settings updated successfully.", "Saved");
      if (pwInput) pwInput.value = "";
      if (confirmInput) confirmInput.value = "";
      if (meter) meter.setAttribute("data-level", "0");
    });
  }
}

/* -------------------------------------------------------------
   SAVE PUBLIC PROFILE HANDLER
   ------------------------------------------------------------- */
function initSaveProfile() {
  var btn = document.getElementById("btnSaveProfile");
  if (!btn) return;

  btn.addEventListener("click", function () {
    AdminToast.success("Public profile and hero configuration saved successfully.", "Profile Updated");
  });
}

/* -------------------------------------------------------------
   LOGOUT ACTION WITH MODAL CONFIRMATION
   ------------------------------------------------------------- */
function initAdminLogout() {
  var logoutBtn = document.getElementById("btnLogout");
  if (!logoutBtn) return;

  logoutBtn.addEventListener("click", function (e) {
    e.preventDefault();
    var baseUrl = logoutBtn.getAttribute("data-redirect") || "../../Auth/SignIn.aspx";

    AdminModal.confirm({
      title: "Log Out",
      message: "Are you sure you want to terminate your administrative session?",
      confirmText: "Log Out",
      type: "danger",
      onConfirm: function () {
        AdminToast.info("Logging out of Admin Console...", "Signing Out");
        setTimeout(function () {
          window.location.href = baseUrl;
        }, 600);
      }
    });
  });
}

/* -------------------------------------------------------------
   TABLE ACTIONS (EDIT, DELETE & USER STATUS MODALS)
   ------------------------------------------------------------- */
function initTableActions() {
  // Delegate delete actions
  document.addEventListener("click", function (e) {
    var deleteLink = e.target.closest(".data-table td a.danger:not(.user-status-toggle)");
    if (deleteLink) {
      e.preventDefault();
      var row = deleteLink.closest("tr");
      var label = row ? row.querySelector("td")?.textContent?.trim() || "item" : "item";

      AdminModal.confirm({
        title: "Delete Record",
        message: "Are you sure you want to delete <strong>\"" + label + "\"</strong>? This action cannot be undone.",
        confirmText: "Delete",
        type: "danger",
        onConfirm: function () {
          if (row) {
            if (typeof gsap !== "undefined") {
              gsap.to(row, {
                opacity: 0,
                x: -20,
                duration: 0.25,
                onComplete: function () {
                  row.remove();
                }
              });
            } else {
              row.remove();
            }
          }
          AdminToast.success("Record has been permanently deleted.", "Deleted");
        }
      });
      return;
    }

    // Delegate edit actions
    var editLink = e.target.closest(".data-table td a:not(.danger):not(.user-status-toggle)");
    if (editLink) {
      e.preventDefault();
      var editRow = editLink.closest("tr");
      var editLabel = editRow ? editRow.querySelector("td")?.textContent?.trim() || "item" : "item";
      AdminToast.info("Editing enabled for \"" + editLabel + "\".", "Edit Mode");
      return;
    }

    // Delegate user status toggles
    var toggleBtn = e.target.closest(".user-status-toggle");
    if (toggleBtn) {
      e.preventDefault();
      var userRow = toggleBtn.closest("tr");
      var pill = userRow ? userRow.querySelector(".status-pill") : null;
      var userName = userRow ? userRow.querySelector("td")?.textContent?.trim() || "User" : "User";

      if (!pill) return;

      var isCurrentlyActive = pill.classList.contains("active");

      if (isCurrentlyActive) {
        AdminModal.confirm({
          title: "Deactivate User",
          message: "Are you sure you want to deactivate <strong>" + userName + "</strong>? They will be unable to access their account.",
          confirmText: "Deactivate",
          type: "danger",
          onConfirm: function () {
            pill.classList.remove("active");
            pill.classList.add("inactive");
            pill.textContent = "DEACTIVATED";
            toggleBtn.textContent = "Reactivate";
            toggleBtn.classList.remove("danger");
            AdminToast.warning("User " + userName + " has been deactivated.", "Account Deactivated");
          }
        });
      } else {
        AdminModal.confirm({
          title: "Reactivate User",
          message: "Restore sign-in access for <strong>" + userName + "</strong>?",
          confirmText: "Reactivate",
          type: "primary",
          onConfirm: function () {
            pill.classList.remove("inactive");
            pill.classList.add("active");
            pill.textContent = "ACTIVE";
            toggleBtn.textContent = "Deactivate";
            toggleBtn.classList.add("danger");
            AdminToast.success("User " + userName + " has been reactivated.", "Account Active");
          }
        });
      }
    }
  });
}

/* -------------------------------------------------------------
   ADD FORM ACTIONS (DYNAMIC ROW INSERTION & VALIDATION)
   ------------------------------------------------------------- */
function initAddFormActions() {
  document.querySelectorAll(".admin-panel").forEach(function (panel) {
    var panelName = panel.getAttribute("data-panel");
    var addBtn = panel.querySelector(".add-form .btn-primary");
    var tableBody = panel.querySelector(".data-table tbody");
    if (!addBtn || !tableBody) return;

    addBtn.addEventListener("click", function (e) {
      e.preventDefault();
      var form = addBtn.closest(".add-form");
      var inputs = form.querySelectorAll("input:not([type='hidden']), textarea, select");
      var values = [];
      var hasValue = false;

      inputs.forEach(function (input) {
        var v = input.value.trim();
        if (v) hasValue = true;
        values.push(v);
      });

      if (!hasValue) {
        AdminToast.warning("Please fill out the form fields before adding.", "Required Fields");
        return;
      }

      // Format row according to panel
      var tr = document.createElement("tr");
      var actionsTd = '<td><a href="javascript:void(0)">Edit</a><a href="javascript:void(0)" class="danger">Delete</a></td>';

      if (panelName === "techstack") {
        var group = values[0] || "General";
        var label = values[1] || "Item";
        var icon = values[2] || "Assets/Icons/default.svg";
        tr.innerHTML = "<td>" + group + "</td><td>" + label + "</td><td>" + icon + "</td>" + actionsTd;
      } else if (panelName === "skills") {
        var skill = values[0] || "Skill";
        var level = values[1] || "INTERMEDIATE";
        var segs = values[2] || "5";
        var ctx = values[3] || "General";
        tr.innerHTML = "<td>" + skill + "</td><td>" + level + "</td><td>" + segs + "</td><td>" + ctx + "</td>" + actionsTd;
      } else if (panelName === "experience") {
        var role = values[0] || "Role";
        var comp = values[1] || "Company";
        var per = values[2] || "2026";
        var tags = values[3] || "Web";
        var desc = values[4] || "Description of position";
        tr.innerHTML = "<td>" + role + "</td><td>" + comp + "</td><td>" + per + "</td><td>" + desc + "</td><td>" + tags + "</td>" + actionsTd;
      } else if (panelName === "projects") {
        var title = values[0] || "Project";
        var img = values[1] || "Assets/Images/default.png";
        var pTags = values[3] || "HTML, CSS";
        tr.innerHTML = "<td>" + title + "</td><td>" + img + "</td><td>" + pTags + "</td>" + actionsTd;
      } else if (panelName === "education") {
        var yr = values[0] || "2024 — 2026";
        var deg = values[1] || "Degree";
        var sub = values[2] || "Field";
        var org = values[3] || "University";
        tr.innerHTML = "<td>" + yr + "</td><td>" + deg + "</td><td>" + sub + "</td><td>" + org + "</td>" + actionsTd;
      } else if (panelName === "awards") {
        var aYr = values[0] || "2026";
        var aTit = values[1] || "Award";
        var aSub = values[2] || "Recognition";
        var aOrg = values[3] || "Organization";
        tr.innerHTML = "<td>" + aYr + "</td><td>" + aTit + "</td><td>" + aSub + "</td><td>" + aOrg + "</td>" + actionsTd;
      } else if (panelName === "hobbies") {
        var hobby = values[0] || "New Hobby";
        tr.innerHTML = "<td>" + hobby + '</td><td><a href="javascript:void(0)" class="danger">Remove</a></td>';
      }

      tableBody.appendChild(tr);

      // Animate new row
      if (typeof gsap !== "undefined") {
        gsap.fromTo(tr, { opacity: 0, y: 12 }, { opacity: 1, y: 0, duration: 0.3 });
      }

      // Reset form inputs (except date pickers' flatpickr instances if any)
      inputs.forEach(function (inp) {
        if (!inp.classList.contains("chip-input")) {
          inp.value = "";
        }
      });

      // Clear chips if present
      var chipsList = form.querySelector(".chips-list");
      if (chipsList) chipsList.innerHTML = "";
      var hiddenTarget = form.querySelector(".chips-container")?.getAttribute("data-input-target");
      if (hiddenTarget) {
        var hInp = document.getElementById(hiddenTarget);
        if (hInp) hInp.value = "";
      }

      AdminToast.success("New entry added to " + (panel.querySelector("h2")?.textContent || "table") + ".", "Record Added");
    });
  });
}

/* =============================================================
   REUSABLE TOAST NOTIFICATION SYSTEM
   ============================================================= */
var AdminToast = (function () {
  function getContainer() {
    var container = document.getElementById("adminToastContainer");
    if (!container) {
      container = document.createElement("div");
      container.id = "adminToastContainer";
      container.className = "admin-toast-container";
      container.setAttribute("aria-live", "polite");
      document.body.appendChild(container);
    }
    return container;
  }

  var icons = {
    success: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>',
    danger: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    error: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    warning: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    info: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>'
  };

  function show(options) {
    if (typeof options === "string") {
      options = { message: options, type: "success" };
    }
    var msg = options.message || "";
    var title = options.title || "";
    var type = options.type || "success";
    var duration = typeof options.duration === "number" ? options.duration : 3500;

    var container = getContainer();
    var card = document.createElement("div");
    card.className = "admin-toast-card toast-" + type;

    var iconHtml = icons[type] || icons.info;
    var titleHtml = title ? '<div class="admin-toast-title">' + title + '</div>' : '';

    card.innerHTML =
      '<div class="admin-toast-icon">' + iconHtml + '</div>' +
      '<div class="admin-toast-body">' +
        titleHtml +
        '<div class="admin-toast-message">' + msg + '</div>' +
      '</div>' +
      '<button type="button" class="admin-toast-close" title="Dismiss">&times;</button>' +
      '<div class="admin-toast-progress"><div class="admin-toast-progress-bar"></div></div>';

    container.appendChild(card);

    var progressBar = card.querySelector(".admin-toast-progress-bar");
    var closeBtn = card.querySelector(".admin-toast-close");
    var progressTween = null;
    var isDismissed = false;

    function dismiss() {
      if (isDismissed) return;
      isDismissed = true;
      if (typeof gsap !== "undefined") {
        gsap.to(card, {
          opacity: 0,
          x: 40,
          duration: 0.22,
          ease: "power2.in",
          onComplete: function () {
            card.remove();
          }
        });
      } else {
        card.remove();
      }
    }

    closeBtn.addEventListener("click", dismiss);

    // GSAP entrance animation
    if (typeof gsap !== "undefined") {
      gsap.fromTo(
        card,
        { opacity: 0, x: 40, scale: 0.95 },
        { opacity: 1, x: 0, scale: 1, duration: 0.25, ease: "power2.out" }
      );

      if (duration > 0 && progressBar) {
        progressTween = gsap.fromTo(
          progressBar,
          { scaleX: 1 },
          {
            scaleX: 0,
            duration: duration / 1000,
            ease: "none",
            onComplete: dismiss
          }
        );

        card.addEventListener("mouseenter", function () {
          if (progressTween) progressTween.pause();
        });
        card.addEventListener("mouseleave", function () {
          if (progressTween) progressTween.play();
        });
      }
    } else if (duration > 0) {
      setTimeout(dismiss, duration);
    }

    return card;
  }

  return {
    show: show,
    success: function (msg, title) { return show({ message: msg, title: title, type: "success" }); },
    error: function (msg, title) { return show({ message: msg, title: title, type: "danger" }); },
    warning: function (msg, title) { return show({ message: msg, title: title, type: "warning" }); },
    info: function (msg, title) { return show({ message: msg, title: title, type: "info" }); }
  };
})();
window.AdminToast = AdminToast;

/* =============================================================
   REUSABLE MODAL DIALOG COMPONENT
   ============================================================= */
var AdminModal = (function () {
  var overlay, dialog, titleElem, iconElem, msgElem, confirmBtn, cancelBtn, closeBtn;
  var currentConfirmCallback = null;
  var currentCancelCallback = null;

  function initElements() {
    overlay = document.getElementById("adminModalOverlay");
    if (!overlay) {
      overlay = document.createElement("div");
      overlay.id = "adminModalOverlay";
      overlay.className = "admin-modal-overlay";
      overlay.setAttribute("aria-hidden", "true");
      overlay.innerHTML =
        '<div class="admin-modal-dialog" id="adminModalDialog" role="dialog" aria-modal="true">' +
          '<div class="admin-modal-header">' +
            '<div class="admin-modal-title" id="adminModalTitle">' +
              '<span class="admin-modal-title-icon" id="adminModalIcon"></span>' +
              '<span id="adminModalTitleText">Confirmation</span>' +
            '</div>' +
            '<button type="button" class="admin-modal-close-btn" id="adminModalCloseBtn" title="Close modal" aria-label="Close modal">&times;</button>' +
          '</div>' +
          '<div class="admin-modal-body" id="adminModalBody">' +
            '<p id="adminModalMessage">Are you sure you want to proceed?</p>' +
          '</div>' +
          '<div class="admin-modal-footer" id="adminModalFooter">' +
            '<button type="button" class="btn btn-secondary" id="adminModalCancelBtn">Cancel</button>' +
            '<button type="button" class="btn btn-primary" id="adminModalConfirmBtn">Confirm</button>' +
          '</div>' +
        '</div>';
      document.body.appendChild(overlay);
    }

    dialog = overlay.querySelector(".admin-modal-dialog");
    titleElem = overlay.querySelector("#adminModalTitleText");
    iconElem = overlay.querySelector("#adminModalIcon");
    msgElem = overlay.querySelector("#adminModalMessage");
    confirmBtn = overlay.querySelector("#adminModalConfirmBtn");
    cancelBtn = overlay.querySelector("#adminModalCancelBtn");
    closeBtn = overlay.querySelector("#adminModalCloseBtn");

    closeBtn.addEventListener("click", close);
    cancelBtn.addEventListener("click", function () {
      if (typeof currentCancelCallback === "function") currentCancelCallback();
      close();
    });
    confirmBtn.addEventListener("click", function () {
      if (typeof currentConfirmCallback === "function") currentConfirmCallback();
      close();
    });

    overlay.addEventListener("click", function (e) {
      if (e.target === overlay) {
        if (typeof currentCancelCallback === "function") currentCancelCallback();
        close();
      }
    });

    window.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && overlay.classList.contains("active")) {
        if (typeof currentCancelCallback === "function") currentCancelCallback();
        close();
      }
    });
  }

  function close() {
    if (!overlay) return;
    if (typeof gsap !== "undefined" && dialog) {
      gsap.to(dialog, {
        scale: 0.95,
        opacity: 0,
        y: -10,
        duration: 0.18,
        ease: "power2.in",
        onComplete: function () {
          overlay.classList.remove("active");
          overlay.setAttribute("aria-hidden", "true");
        }
      });
    } else {
      overlay.classList.remove("active");
      overlay.setAttribute("aria-hidden", "true");
    }
  }

  function confirm(options) {
    if (!overlay) initElements();

    options = options || {};
    var title = options.title || "Confirm Action";
    var message = options.message || "Are you sure you want to proceed?";
    var confirmText = options.confirmText || "Confirm";
    var cancelText = options.cancelText || "Cancel";
    var type = options.type || "primary";

    currentConfirmCallback = options.onConfirm || null;
    currentCancelCallback = options.onCancel || null;

    if (titleElem) titleElem.textContent = title;
    if (msgElem) msgElem.innerHTML = message;
    if (confirmBtn) {
      confirmBtn.textContent = confirmText;
      confirmBtn.className = "btn " + (type === "danger" ? "btn-danger" : "btn-primary");
    }
    if (cancelBtn) {
      cancelBtn.textContent = cancelText;
      cancelBtn.style.display = options.showCancel === false ? "none" : "inline-flex";
    }

    var iconSvg = "";
    if (type === "danger") {
      iconSvg = '<svg viewBox="0 0 24 24" fill="none" stroke="var(--danger)" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>';
    } else {
      iconSvg = '<svg viewBox="0 0 24 24" fill="none" stroke="var(--cyan)" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>';
    }
    if (iconElem) iconElem.innerHTML = iconSvg;

    overlay.classList.add("active");
    overlay.setAttribute("aria-hidden", "false");

    if (typeof gsap !== "undefined" && dialog) {
      gsap.fromTo(
        dialog,
        { scale: 0.9, opacity: 0, y: -20 },
        { scale: 1, opacity: 1, y: 0, duration: 0.25, ease: "back.out(1.4)" }
      );
    }
  }

  function alert(message, title, onClose) {
    confirm({
      title: title || "Notice",
      message: message,
      confirmText: "OK",
      showCancel: false,
      type: "primary",
      onConfirm: onClose
    });
  }

  return {
    init: initElements,
    confirm: confirm,
    alert: alert,
    close: close
  };
})();
window.AdminModal = AdminModal;
