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
  initImageLivePreviews();
  initAdminProfile();
  initAdminLogout();
  initInputFocus();
  initPasswordToggles();
});

/* -------------------------------------------------------------
   IMAGE LIVE PREVIEW LISTENERS (ADMIN)
   ------------------------------------------------------------- */
function initImageLivePreviews() {
  function formatImgUrl(path) {
    if (!path) return "";
    var clean = path.trim();
    if (
      clean.startsWith("http://") ||
      clean.startsWith("https://") ||
      clean.startsWith("data:")
    ) {
      return clean;
    }
    clean = clean.replace(/^(\~|\/)/, "");
    return "../../" + clean;
  }

  // Profile Avatar live preview
  var fuProfileAvatar = document.querySelector("input[id*='fuProfileAvatar']");
  var boxProfileAvatar = document.querySelector(
    "[id*='profileAvatarPreviewBox']",
  );
  var imgProfileAvatar = document.querySelector(
    "img[id*='imgProfileAvatarThumb']",
  );
  var hidExistingAvatar = document.querySelector(
    "input[id*='hidExistingAvatarPath']",
  );

  if (fuProfileAvatar && imgProfileAvatar) {
    fuProfileAvatar.addEventListener("change", function (e) {
      var file = e.target.files && e.target.files[0];
      if (file) {
        var reader = new FileReader();
        reader.onload = function (evt) {
          imgProfileAvatar.src = evt.target.result;
          if (boxProfileAvatar) boxProfileAvatar.style.display = "flex";
        };
        reader.readAsDataURL(file);
        if (typeof AdminToast !== "undefined") {
          AdminToast.info(
            "Avatar image selected: " +
              file.name +
              ". Click Save Profile to apply.",
            "Avatar Ready",
          );
        }
      } else {
        if (!hidExistingAvatar || !hidExistingAvatar.value) {
          if (boxProfileAvatar) boxProfileAvatar.style.display = "none";
        }
      }
    });
  }

  // Project Image live preview
  var fuProjImg = document.querySelector("input[id*='fuProjectImage']");
  var boxProjImg =
    document.getElementById("projectImgPreviewBox") ||
    document.querySelector("[id*='projectImgPreviewBox']");
  var imgProj =
    document.getElementById("projectFormImgPreview") ||
    document.querySelector("img[id*='projectFormImgPreview']");
  var hidExistingProjImg = document.querySelector(
    "input[id*='hidExistingImagePath']",
  );

  if (fuProjImg && imgProj) {
    fuProjImg.addEventListener("change", function (e) {
      var file = e.target.files && e.target.files[0];
      if (file) {
        var reader = new FileReader();
        reader.onload = function (evt) {
          imgProj.src = evt.target.result;
          if (boxProjImg) boxProjImg.style.display = "flex";
        };
        reader.readAsDataURL(file);
        if (typeof AdminToast !== "undefined") {
          AdminToast.info(
            "Project image selected: " +
              file.name +
              ". Click Add/Update Project to save.",
            "Image Ready",
          );
        }
      } else {
        if (!hidExistingProjImg || !hidExistingProjImg.value) {
          if (boxProjImg) boxProjImg.style.display = "none";
        }
      }
    });
  }
}

/* -------------------------------------------------------------
   INPUT UNDERLINE FOCUS STATE (ADMIN)
   ------------------------------------------------------------- */
function initInputFocus() {
  document
    .querySelectorAll(
      ".field input, .field select, .input-row input, .input-row select",
    )
    .forEach(function (input) {
      var row = input.closest(".input-row") || input.closest(".field");
      input.addEventListener("focus", function () {
        if (row) row.classList.add("focused");
      });
      input.addEventListener("blur", function () {
        if (row) row.classList.remove("focused");
      });
    });
}

/* -------------------------------------------------------------
   CUSTOM INVERTING CURSOR (ADMIN - GSAP ENHANCED)
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
  var mouseX = window.innerWidth / 2;
  var mouseY = window.innerHeight / 2;
  var isMoved = false;
  var isHovered = false;

  gsap.set(cursor, { xPercent: -50, yPercent: -50 });

  var xTo = gsap.quickTo(cursor, "x", { duration: 0.22, ease: "power2.out" });
  var yTo = gsap.quickTo(cursor, "y", { duration: 0.22, ease: "power2.out" });

  window.addEventListener("mousemove", function (e) {
    mouseX = e.clientX;
    mouseY = e.clientY;
    xTo(mouseX);
    yTo(mouseY);
    if (!isMoved) {
      cursor.classList.add("is-visible");
      isMoved = true;
    }
  });

  document.addEventListener("mouseleave", function () {
    cursor.classList.remove("is-visible");
    isMoved = false;
  });

  document.addEventListener("mouseenter", function () {
    cursor.classList.add("is-visible");
    isMoved = true;
  });

  // Subtle click animation
  window.addEventListener("mousedown", function () {
    cursor.classList.add("is-active");
    if (dot) {
      gsap.to(dot, {
        scale: isHovered ? 1.15 : 0.85,
        duration: 0.15,
        ease: "power2.out",
      });
    }
  });

  window.addEventListener("mouseup", function () {
    cursor.classList.remove("is-active");
    if (dot) {
      gsap.to(dot, {
        scale: isHovered ? 1.25 : 1,
        duration: 0.18,
        ease: "power2.out",
      });
    }
  });

  // Hover targets with delegation & GSAP scale
  var hoverSelector =
    "a, button, input, textarea, select, .nav-item, .btn, .sidebar-toggle-btn, .admin-logout-btn, .admin-avatar-box, .status-pill, .chip, .chip-tag, .chip-remove, .chip-input, .chips-container, .data-table tr, .dash-kpi-card, .jump-panel-btn";

  document.addEventListener("mouseover", function (e) {
    if (e.target && e.target.closest(hoverSelector)) {
      if (!isHovered) {
        isHovered = true;
        cursor.classList.add("is-hover");
        if (dot) {
          gsap.to(dot, { scale: 1.25, duration: 0.22, ease: "power2.out" });
        }
      }
    }
  });

  document.addEventListener("mouseout", function (e) {
    if (e.target && e.target.closest(hoverSelector)) {
      isHovered = false;
      cursor.classList.remove("is-hover");
      if (dot) {
        gsap.to(dot, { scale: 1, duration: 0.22, ease: "power2.out" });
      }
    }
  });
}

/* -------------------------------------------------------------
   SIDEBAR COLLAPSIBLE OPEN / CLOSE (GSAP ENHANCED)
   ------------------------------------------------------------- */
function initAdminSidebarAnimations() {
  var shell = document.getElementById("adminShell");
  var nav = document.getElementById("adminNav");
  var toggleBtn = document.getElementById("btnToggleSidebar");
  var backdrop = document.getElementById("adminSidebarBackdrop");
  if (!shell || !nav || !toggleBtn) return;

  function isMobileView() {
    return window.innerWidth <= 800;
  }

  var savedCollapsed = localStorage.getItem("admin_sidebar_collapsed");
  var isCollapsed =
    savedCollapsed !== null ? savedCollapsed === "true" : isMobileView();

  function setSidebarState(collapsed, animate) {
    var isMobile = isMobileView();

    if (collapsed) {
      shell.classList.add("sidebar-collapsed");
      shell.classList.remove("sidebar-mobile-expanded");

      if (animate) {
        if (!isMobile) {
          gsap.fromTo(
            nav,
            { width: 240 },
            {
              width: 56,
              duration: 0.28,
              ease: "power2.out",
              clearProps: "width",
            }
          );
        }
        var labels = nav.querySelectorAll(".nav-label, .admin-profile-summary");
        if (labels.length > 0) {
          gsap.to(labels, { opacity: 0, duration: 0.15, ease: "power1.out" });
        }
      } else {
        nav.style.width = "";
      }
    } else {
      shell.classList.remove("sidebar-collapsed");
      if (isMobile) {
        shell.classList.add("sidebar-mobile-expanded");
      } else {
        shell.classList.remove("sidebar-mobile-expanded");
      }

      if (animate) {
        if (!isMobile) {
          gsap.fromTo(
            nav,
            { width: 56 },
            {
              width: 240,
              duration: 0.28,
              ease: "power2.out",
              clearProps: "width",
            }
          );
        }
        var labels = nav.querySelectorAll(".nav-label, .admin-profile-summary");
        if (labels.length > 0) {
          gsap.fromTo(
            labels,
            { opacity: 0, x: -4 },
            {
              opacity: 1,
              x: 0,
              stagger: 0.02,
              duration: 0.22,
              ease: "power2.out",
            }
          );
        }
      } else {
        nav.style.width = "";
      }
    }
  }

  // Initial set without animation
  setSidebarState(isCollapsed, false);

  toggleBtn.addEventListener("click", function (e) {
    e.stopPropagation();
    isCollapsed = !isCollapsed;
    localStorage.setItem("admin_sidebar_collapsed", isCollapsed);
    setSidebarState(isCollapsed, true);
  });

  if (backdrop) {
    backdrop.addEventListener("click", function () {
      if (!isCollapsed && isMobileView()) {
        isCollapsed = true;
        localStorage.setItem("admin_sidebar_collapsed", isCollapsed);
        setSidebarState(isCollapsed, true);
      }
    });
  }

  nav.querySelectorAll(".nav-item").forEach(function (item) {
    item.addEventListener("click", function () {
      if (isMobileView() && !isCollapsed) {
        isCollapsed = true;
        localStorage.setItem("admin_sidebar_collapsed", isCollapsed);
        setSidebarState(isCollapsed, true);
      }
    });
  });

  var resizeTimer;
  window.addEventListener("resize", function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function () {
      var mobile = isMobileView();
      if (!mobile && shell.classList.contains("sidebar-mobile-expanded")) {
        shell.classList.remove("sidebar-mobile-expanded");
      }
      setSidebarState(isCollapsed, false);
    }, 120);
  });
}



/* -------------------------------------------------------------
   TAB PANEL NAVIGATION & ROUTING
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
      p.classList.toggle("active", match);
    });

    if (hidden) {
      hidden.value = panelName;
    }

    if (titleDisplay) {
      var activeLink = document.querySelector(
        '.admin-nav a[data-panel="' + panelName + '"] .nav-label',
      );
      if (activeLink) {
        titleDisplay.textContent = activeLink.textContent;
      } else if (panelName === "dashboard") {
        titleDisplay.textContent = "Dashboard";
      }
    }

    if (panelName !== "techstack") {
      safeEncodeSvgCode();
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

  // Jump buttons on Dashboard or other panels
  document.addEventListener("click", function (e) {
    var jumpBtn = e.target.closest(".jump-panel-btn");
    if (jumpBtn) {
      var target = jumpBtn.getAttribute("data-target");
      if (target) {
        activatePanel(target);
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
    }
  });

  // Initial active panel (defaults to dashboard)
  var savedPanel = localStorage.getItem("admin_active_panel");
  var initial =
    hidden && hidden.value ? hidden.value : savedPanel || "dashboard";
  activatePanel(initial);
}

// Print / Export report function
window.printReportSummary = function () {
  window.print();
};

/* -------------------------------------------------------------
   INPUT CHIPS COMPONENT
   ------------------------------------------------------------- */
function initInputChips() {
  document.querySelectorAll(".chips-container").forEach(function (container) {
    var hiddenId = container.getAttribute("data-input-target");
    var getHidden = function () {
      return hiddenId
        ? document.getElementById(hiddenId) ||
            container.querySelector("#" + hiddenId) ||
            container.parentElement.querySelector("#" + hiddenId) ||
            document.querySelector("input[id$='" + hiddenId + "']") ||
            document.querySelector("input[name$='" + hiddenId + "']")
        : null;
    };
    var hiddenInput = getHidden();
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
      var hInp = getHidden();
      if (!hInp) return;
      var tags = [];
      chipsList
        .querySelectorAll(".chip-tag span:first-child")
        .forEach(function (t) {
          var txt = t.textContent.trim();
          if (txt) tags.push(txt);
        });
      hInp.value = tags.join(",");
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

    // Initial sync so hidden field immediately matches rendered chips
    syncHidden();

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

function commitAllChips() {
  document.querySelectorAll(".chips-container").forEach(function (container) {
    var chipInput = container.querySelector(".chip-input");
    var chipsList = container.querySelector(".chips-list");
    var hiddenId = container.getAttribute("data-input-target");
    var hInp = hiddenId
      ? document.getElementById(hiddenId) ||
        container.querySelector("#" + hiddenId) ||
        container.parentElement.querySelector("#" + hiddenId) ||
        document.querySelector("input[id$='" + hiddenId + "']") ||
        document.querySelector("input[name$='" + hiddenId + "']")
      : null;

    if (chipInput && chipInput.value.trim()) {
      var val = chipInput.value.replace(/,/g, "").trim();
      if (val && chipsList) {
        var tag = document.createElement("span");
        tag.className = "chip-tag";
        tag.innerHTML =
          "<span>" +
          val +
          '</span><span class="chip-remove" title="Remove">&times;</span>';
        chipsList.appendChild(tag);
        chipInput.value = "";
      }
    }

    if (hInp && chipsList) {
      var tags = [];
      chipsList
        .querySelectorAll(".chip-tag span:first-child")
        .forEach(function (t) {
          var txt = t.textContent.trim();
          if (txt) tags.push(txt);
        });
      hInp.value = tags.join(",");
    }
  });
}

function safeEncodeSvgCode() {
  var txtSvg =
    document.getElementById("txtTechSvgCode") ||
    document.querySelector("textarea[id*='txtTechSvgCode']");
  if (
    txtSvg &&
    txtSvg.value &&
    txtSvg.value.trim().indexOf("<") >= 0 &&
    !txtSvg.value.startsWith("base64:")
  ) {
    try {
      txtSvg.value =
        "base64:" + btoa(unescape(encodeURIComponent(txtSvg.value.trim())));
    } catch (err) {}
  }
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
  var previewImg =
    document.getElementById("adminAvatarPreview") ||
    document.getElementById("imgAdminAvatar") ||
    document.querySelector(".avatar-preview-container .account-avatar-img");
  var svgPlaceholder =
    document.getElementById("adminAvatarSvgPlaceholder") ||
    document.querySelector(".avatar-svg-placeholder");
  if (!uploadInput) return;

  uploadInput.addEventListener("change", function (e) {
    var file = e.target.files && e.target.files[0];
    if (file) {
      var reader = new FileReader();
      reader.onload = function (evt) {
        if (!previewImg) {
          previewImg =
            document.getElementById("adminAvatarPreview") ||
            document.getElementById("imgAdminAvatar") ||
            document.querySelector(
              ".avatar-preview-container .account-avatar-img",
            );
        }
        if (previewImg) {
          previewImg.src = evt.target.result;
          previewImg.style.display = "block";
        }
        if (svgPlaceholder) svgPlaceholder.style.display = "none";
      };
      reader.readAsDataURL(file);
      if (typeof AdminToast !== "undefined") {
        AdminToast.info(
          "Admin avatar selected: " +
            file.name +
            ". Click Save Changes to apply.",
          "Avatar Ready",
        );
      }
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
    saveBtn.addEventListener("click", function (e) {
      var newPw = pwInput ? pwInput.value.trim() : "";
      var confirmPw = confirmInput ? confirmInput.value.trim() : "";

      if (newPw) {
        if (newPw.length < 8) {
          e.preventDefault();
          AdminToast.warning(
            "Password must be at least 8 characters.",
            "Security Warning",
          );
          return false;
        }
        if (newPw !== confirmPw) {
          e.preventDefault();
          AdminToast.error(
            "Passwords do not match. Please verify your new password.",
            "Validation Error",
          );
          return false;
        }
      }
    });
  }
}

/* -------------------------------------------------------------
   PASSWORD VISIBILITY TOGGLE HELPER (ADMIN)
   ------------------------------------------------------------- */
function initPasswordToggles() {
  document.querySelectorAll(".password-toggle-btn").forEach(function (btn) {
    if (btn.dataset.toggleBound) return;
    btn.dataset.toggleBound = "true";

    btn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();

      var row = btn.closest(".input-row") || btn.closest(".field");
      if (!row) return;

      var input = row.querySelector("input");
      if (!input) return;

      var eyeClosed = btn.querySelector(".eye-closed");
      var eyeOpen = btn.querySelector(".eye-open");

      if (input.type === "password") {
        input.type = "text";
        if (eyeClosed) eyeClosed.style.display = "none";
        if (eyeOpen) eyeOpen.style.display = "block";
        btn.setAttribute("aria-label", "Hide password");
        btn.setAttribute("title", "Hide password");
      } else {
        input.type = "password";
        if (eyeClosed) eyeClosed.style.display = "block";
        if (eyeOpen) eyeOpen.style.display = "none";
        btn.setAttribute("aria-label", "Show password");
        btn.setAttribute("title", "Show password");
      }

      try {
        var len = input.value.length;
        input.setSelectionRange(len, len);
      } catch (err) {}
    });
  });
}

/* -------------------------------------------------------------
   SAVE PUBLIC PROFILE HANDLER
   ------------------------------------------------------------- */
function initSaveProfile() {
  // Handled cleanly via server postback with true database status toast
}

/* -------------------------------------------------------------
   LOGOUT ACTION WITH MODAL CONFIRMATION
   ------------------------------------------------------------- */
function initAdminLogout() {
  var logoutBtn = document.getElementById("btnLogout");
  if (!logoutBtn) return;

  logoutBtn.addEventListener("click", function (e) {
    e.preventDefault();
    var baseUrl =
      logoutBtn.getAttribute("data-redirect") ||
      "../../Auth/SignIn.aspx?logout=true";

    if (typeof AdminModal !== "undefined" && AdminModal.confirm) {
      AdminModal.confirm({
        title: "Log Out",
        message:
          "Are you sure you want to terminate your administrative session?",
        confirmText: "Log Out",
        type: "danger",
        onConfirm: function () {
          window.location.href = baseUrl;
        },
      });
    } else {
      window.location.href = baseUrl;
    }
  });
}

/* -------------------------------------------------------------
   FORM & INPUT VALIDATION ENGINE
   ------------------------------------------------------------- */
function validateAdminForm(trigger) {
  var container = trigger.closest(
    ".add-form, .admin-profile-card, .admin-panel, form",
  );
  if (!container) return { valid: true };

  // Clear previous error highlights
  container.querySelectorAll(".input-error, .has-error").forEach(function (el) {
    el.classList.remove("input-error", "has-error");
  });

  var inputs = container.querySelectorAll(
    "input:not([type='hidden']), textarea, select",
  );
  var firstInvalid = null;
  var errorMsg = "";

  for (var i = 0; i < inputs.length; i++) {
    var inp = inputs[i];
    if (inp.disabled || inp.offsetParent === null) continue;

    var val = inp.value.trim();
    var labelElem = inp.closest(".field")
      ? inp.closest(".field").querySelector("label")
      : null;
    var fieldName = labelElem
      ? labelElem.textContent.replace(/[\*\:]/g, "").trim()
      : inp.placeholder || "Field";

    var isRequired =
      inp.hasAttribute("required") ||
      inp.getAttribute("aria-required") === "true";
    var isAddFormBtn =
      trigger.classList.contains("btn-primary") && trigger.closest(".add-form");

    // Special handling for file uploads
    if (inp.type === "file") {
      var fieldWrap = inp.closest(".field") || inp.parentElement;
      var previewBox = fieldWrap
        ? fieldWrap.querySelector("[id*='Preview'], [id*='preview'], img")
        : null;
      var hiddenExisting = fieldWrap
        ? fieldWrap.querySelector(
            "input[id*='Existing'], input[id*='existing'], input[id*='hidExisting']",
          )
        : null;
      var hasExisting =
        (hiddenExisting &&
          hiddenExisting.value &&
          hiddenExisting.value.trim() !== "") ||
        (previewBox &&
          previewBox.offsetParent !== null &&
          previewBox.style.display !== "none");
      var hasFiles = inp.files && inp.files.length > 0;
      if (isRequired && !hasExisting && !hasFiles) {
        firstInvalid = inp;
        errorMsg = 'Please choose a file for "' + fieldName + '".';
        break;
      }
      // Never block if optional or existing image preview is present
      continue;
    }

    if (
      (isRequired ||
        (isAddFormBtn &&
          !inp.classList.contains("chip-input") &&
          !inp.id.includes("SvgCode") &&
          !inp.id.includes("Url") &&
          !inp.id.includes("Description"))) &&
      !val
    ) {
      firstInvalid = inp;
      errorMsg = 'Please fill out "' + fieldName + '" before proceeding.';
      break;
    }

    if (inp.type === "number" && val !== "") {
      var num = parseFloat(val);
      var min = inp.hasAttribute("min")
        ? parseFloat(inp.getAttribute("min"))
        : null;
      var max = inp.hasAttribute("max")
        ? parseFloat(inp.getAttribute("max"))
        : null;
      if (isNaN(num)) {
        firstInvalid = inp;
        errorMsg = '"' + fieldName + '" must be a valid number.';
        break;
      }
      if (min !== null && num < min) {
        firstInvalid = inp;
        errorMsg = '"' + fieldName + '" cannot be less than ' + min + ".";
        break;
      }
      if (max !== null && num > max) {
        firstInvalid = inp;
        errorMsg = '"' + fieldName + '" cannot be greater than ' + max + ".";
        break;
      }
    }

    if (
      (inp.type === "email" || inp.id.toLowerCase().indexOf("email") >= 0) &&
      val !== ""
    ) {
      var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(val)) {
        firstInvalid = inp;
        errorMsg = "Please enter a valid email address.";
        break;
      }
    }
  }

  // Check password matching if in admin profile
  var newPw = container.querySelector(
    "#txtAdminNewPassword, #adminNewPassword",
  );
  var confirmPw = container.querySelector(
    "#txtAdminConfirmPassword, #adminConfirmPassword",
  );
  if (newPw && confirmPw && newPw.value.trim() !== "") {
    if (newPw.value.trim().length < 8) {
      firstInvalid = newPw;
      errorMsg = "New password must be at least 8 characters long.";
    } else if (newPw.value !== confirmPw.value) {
      firstInvalid = confirmPw;
      errorMsg = "Passwords do not match. Please retype your new password.";
    }
  }

  if (firstInvalid) {
    firstInvalid.classList.add("input-error");
    var parentField =
      firstInvalid.closest(".field") || firstInvalid.closest(".input-row");
    if (parentField) parentField.classList.add("has-error");
    firstInvalid.focus();
    if (typeof AdminToast !== "undefined") {
      AdminToast.warning(errorMsg, "Validation Error");
    }
    return { valid: false, message: errorMsg };
  }

  return { valid: true };
}

/* -------------------------------------------------------------
   UNIVERSAL MODAL CONFIRMATION INTERCEPTOR
   ------------------------------------------------------------- */
document.addEventListener(
  "click",
  function (e) {
    var trigger = e.target.closest(
      "[data-confirm-title], [data-confirm-msg], .needs-confirm",
    );
    if (trigger && !trigger.dataset.confirmed) {
      commitAllChips();
      safeEncodeSvgCode();

      var type =
        trigger.getAttribute("data-confirm-type") ||
        (trigger.classList.contains("btn-danger") ||
        trigger.classList.contains("danger")
          ? "danger"
          : "primary");

      // Perform validation on Add/Save/Update actions before opening modal
      if (type !== "danger") {
        var valResult = validateAdminForm(trigger);
        if (!valResult.valid) {
          e.preventDefault();
          e.stopPropagation();
          return;
        }
      }

      e.preventDefault();
      e.stopPropagation();

      var title =
        trigger.getAttribute("data-confirm-title") || "Confirm Action";
      var msg =
        trigger.getAttribute("data-confirm-msg") ||
        "Are you sure you want to proceed?";
      var confirmText =
        trigger.getAttribute("data-confirm-btn") ||
        (type === "danger" ? "Delete" : "Save Changes");

      AdminModal.confirm({
        title: title,
        message: msg,
        confirmText: confirmText,
        type: type,
        onConfirm: function () {
          commitAllChips();
          safeEncodeSvgCode();
          trigger.dataset.confirmed = "true";
          var href = trigger.getAttribute("href");
          if (href && href.indexOf("__doPostBack") >= 0) {
            eval(href.replace(/^javascript:/i, ""));
          } else {
            trigger.click();
          }
          setTimeout(function () {
            delete trigger.dataset.confirmed;
          }, 1500);
        },
      });
    }
  },
  true,
);

// Global safety listener on any form submit to ensure chips and SVGs are prepared
document.addEventListener("submit", function () {
  commitAllChips();
  safeEncodeSvgCode();
});

/* =============================================================
   REUSABLE TOAST NOTIFICATION SYSTEM
   ============================================================= */
var AdminToast = (function () {
  var queue = [];

  function getContainer() {
    var container = document.getElementById("adminToastContainer");
    if (!container && document.body) {
      container = document.createElement("div");
      container.id = "adminToastContainer";
      container.className = "admin-toast-container";
      container.setAttribute("aria-live", "polite");
      document.body.appendChild(container);
    }
    return container;
  }

  function flushQueue() {
    while (queue.length > 0) {
      show(queue.shift());
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", flushQueue);
  }

  var icons = {
    success:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>',
    danger:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    error:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    warning:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    info: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>',
  };

  function show(options) {
    if (typeof options === "string") {
      options = { message: options, type: "success" };
    }
    var msg = options.message || "";
    var title = options.title || "";
    var type = options.type || "success";
    if (type === "danger") type = "error";
    var duration =
      typeof options.duration === "number" ? options.duration : 3500;

    var container = getContainer();
    if (!container) {
      queue.push(options);
      return null;
    }
    var card = document.createElement("div");
    card.className = "admin-toast-card toast-" + type;

    var iconHtml = icons[type] || icons.info;
    var titleHtml = title
      ? '<div class="admin-toast-title">' + title + "</div>"
      : "";

    card.innerHTML =
      '<div class="admin-toast-icon">' +
      iconHtml +
      "</div>" +
      '<div class="admin-toast-body">' +
      titleHtml +
      '<div class="admin-toast-message">' +
      msg +
      "</div>" +
      "</div>" +
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
          },
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
        { opacity: 1, x: 0, scale: 1, duration: 0.25, ease: "power2.out" },
      );

      if (duration > 0 && progressBar) {
        progressTween = gsap.fromTo(
          progressBar,
          { scaleX: 1 },
          {
            scaleX: 0,
            duration: duration / 1000,
            ease: "none",
            onComplete: dismiss,
          },
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
    success: function (msg, title) {
      return show({ message: msg, title: title, type: "success" });
    },
    error: function (msg, title) {
      return show({ message: msg, title: title, type: "danger" });
    },
    warning: function (msg, title) {
      return show({ message: msg, title: title, type: "warning" });
    },
    info: function (msg, title) {
      return show({ message: msg, title: title, type: "info" });
    },
  };
})();
window.AdminToast = AdminToast;

/* =============================================================
   REUSABLE MODAL DIALOG COMPONENT
   ============================================================= */
var AdminModal = (function () {
  var overlay,
    dialog,
    titleElem,
    iconElem,
    msgElem,
    confirmBtn,
    cancelBtn,
    closeBtn;
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
        "</div>" +
        '<button type="button" class="admin-modal-close-btn" id="adminModalCloseBtn" title="Close modal" aria-label="Close modal">&times;</button>' +
        "</div>" +
        '<div class="admin-modal-body" id="adminModalBody">' +
        '<p id="adminModalMessage">Are you sure you want to proceed?</p>' +
        "</div>" +
        '<div class="admin-modal-footer" id="adminModalFooter">' +
        '<button type="button" class="btn btn-secondary" id="adminModalCancelBtn">Cancel</button>' +
        '<button type="button" class="btn btn-primary" id="adminModalConfirmBtn">Confirm</button>' +
        "</div>" +
        "</div>";
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
      if (typeof currentConfirmCallback === "function")
        currentConfirmCallback();
      close();
    });

    overlay.addEventListener("click", function (e) {
      if (e.target === overlay) {
        if (typeof currentCancelCallback === "function")
          currentCancelCallback();
        close();
      }
    });

    window.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && overlay.classList.contains("active")) {
        if (typeof currentCancelCallback === "function")
          currentCancelCallback();
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
        },
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
      confirmBtn.className =
        "btn " + (type === "danger" ? "btn-danger" : "btn-primary");
    }
    if (cancelBtn) {
      cancelBtn.textContent = cancelText;
      cancelBtn.style.display =
        options.showCancel === false ? "none" : "inline-flex";
    }

    var iconSvg = "";
    if (type === "danger") {
      iconSvg =
        '<svg viewBox="0 0 24 24" fill="none" stroke="var(--danger)" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>';
    } else {
      iconSvg =
        '<svg viewBox="0 0 24 24" fill="none" stroke="var(--cyan)" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>';
    }
    if (iconElem) iconElem.innerHTML = iconSvg;

    overlay.classList.add("active");
    overlay.setAttribute("aria-hidden", "false");

    if (typeof gsap !== "undefined" && dialog) {
      gsap.fromTo(
        dialog,
        { scale: 0.9, opacity: 0, y: -20 },
        { scale: 1, opacity: 1, y: 0, duration: 0.25, ease: "back.out(1.4)" },
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
      onConfirm: onClose,
    });
  }

  return {
    init: initElements,
    confirm: confirm,
    alert: alert,
    close: close,
  };
})();
window.AdminModal = AdminModal;
