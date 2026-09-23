/* =============================================================
   KEVS PORTFOLIO — AUTHENTICATION SCRIPT (Auth.js)
   Dedicated script for SignIn.aspx, SignUp.aspx, and NewPassword.aspx
   ============================================================= */

var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/* -------------------------------------------------------------
   INPUT FOCUS & REVEAL HELPERS
   ------------------------------------------------------------- */
function initInputFocus() {
  document.querySelectorAll(".field input, .field select, .input-row input, .input-row select").forEach(function (input) {
    var row = input.closest(".input-row") || input.closest(".field");
    input.addEventListener("focus", function () {
      if (row) row.classList.add("focused");
    });
    input.addEventListener("blur", function () {
      if (row) row.classList.remove("focused");
    });
  });
}

function initLoadReveal() {
  var els = document.querySelectorAll(".reveal");
  if (!els || els.length === 0) return;

  if (typeof gsap !== "undefined") {
    gsap.fromTo(
      els,
      { opacity: 0, y: 16 },
      { opacity: 1, y: 0, duration: 0.6, stagger: 0.06, ease: "power2.out", clearProps: "transform" }
    );
  } else {
    els.forEach(function (el, i) {
      el.style.transition = "opacity .5s ease, transform .5s ease";
      el.style.transitionDelay = i * 0.06 + "s";
    });
    setTimeout(function () {
      els.forEach(function (el) {
        el.style.opacity = "1";
        el.style.transform = "translateY(0)";
      });
    }, 40);
  }
}

function markValid(field, isValid) {
  if (!field) return isValid;
  var wrapper = field.closest(".field");
  if (wrapper) {
    wrapper.classList.toggle("invalid", !isValid);
  }
  return isValid;
}

/* -------------------------------------------------------------
   CUSTOM INVERTING CURSOR
   ------------------------------------------------------------- */
function initCustomCursor() {
  var cursor = document.getElementById("customCursor");
  if (!cursor) return;

  if (window.matchMedia && !window.matchMedia("(pointer: fine)").matches) {
    cursor.style.display = "none";
    return;
  }

  var xTo = typeof gsap !== "undefined" ? gsap.quickTo(cursor, "x", { duration: 0.22, ease: "power2.out" }) : null;
  var yTo = typeof gsap !== "undefined" ? gsap.quickTo(cursor, "y", { duration: 0.22, ease: "power2.out" }) : null;
  var isVisible = false;

  window.addEventListener("mousemove", function (e) {
    if (xTo && yTo) {
      xTo(e.clientX);
      yTo(e.clientY);
    }
    if (!isVisible) {
      cursor.style.opacity = "1";
      isVisible = true;
    }
  });

  document.addEventListener("mouseleave", function () {
    cursor.style.opacity = "0";
    isVisible = false;
  });

  document.addEventListener("mouseenter", function () {
    cursor.style.opacity = "1";
    isVisible = true;
  });
}

/* -------------------------------------------------------------
   SIGN IN PAGE
   ------------------------------------------------------------- */
function initSignIn() {
  initInputFocus();
  initLoadReveal();

  var urlParams = new URLSearchParams(window.location.search);
  var prefilledEmail = urlParams.get("email");
  var emailInput = document.getElementById("email");
  if (prefilledEmail && emailInput && !emailInput.value) {
    emailInput.value = prefilledEmail;
  }

  // Clean query string from browser address bar
  if (urlParams.get("registered") || urlParams.get("reset") || urlParams.get("logout") || urlParams.get("req")) {
    if (window.history && window.history.replaceState) {
      window.history.replaceState({}, document.title, window.location.pathname);
    }
  }

  // Forgot password modal handlers
  var forgotLink = document.getElementById("forgotPasswordLink");
  var forgotModal = document.getElementById("forgotPasswordModal");
  var closeForgotBtn = document.getElementById("closeForgotBtn");
  var cancelForgotBtn = document.getElementById("cancelForgotBtn");
  var forgotEmailInput = document.getElementById("forgotEmail");
  var submitForgotReqBtn = document.getElementById("submitForgotReqBtn");

  function closeForgotModal() {
    if (forgotModal) {
      forgotModal.style.display = "none";
      forgotModal.setAttribute("aria-hidden", "true");
    }
  }

  if (forgotLink) {
    forgotLink.addEventListener("click", function (e) {
      e.preventDefault();
      var currentEntered = emailInput ? emailInput.value.trim() : "";
      if (forgotEmailInput && currentEntered) {
        forgotEmailInput.value = currentEntered;
      }
      if (forgotModal) {
        forgotModal.style.display = "flex";
        forgotModal.setAttribute("aria-hidden", "false");
      }
    });
  }

  if (closeForgotBtn) closeForgotBtn.addEventListener("click", closeForgotModal);
  if (cancelForgotBtn) cancelForgotBtn.addEventListener("click", closeForgotModal);
  if (forgotModal) {
    forgotModal.addEventListener("click", function (e) {
      if (e.target === forgotModal) closeForgotModal();
    });
  }

  if (submitForgotReqBtn && forgotEmailInput) {
    submitForgotReqBtn.addEventListener("click", function (e) {
      var emailVal = forgotEmailInput.value.trim();
      if (!EMAIL_RE.test(emailVal)) {
        if (e) e.preventDefault();
        forgotEmailInput.closest(".field")?.classList.add("invalid");
      } else {
        forgotEmailInput.closest(".field")?.classList.remove("invalid");
      }
    });
  }

  // Enter key support for signin
  var passInput = document.getElementById("password");
  var signInBtn = document.getElementById("signInBtn");
  [emailInput, passInput].forEach(function (el) {
    if (el) {
      el.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && signInBtn) {
          e.preventDefault();
          signInBtn.click();
        }
      });
    }
  });
}

/* -------------------------------------------------------------
   SIGN UP PAGE
   ------------------------------------------------------------- */
function initSignUp() {
  initInputFocus();
  initLoadReveal();

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
  var strengthLabel = document.getElementById("strengthLabel");
  var STRENGTH_LABELS = ["", "Weak", "Fair", "Strong"];
  var STRENGTH_COLORS = ["", "var(--danger)", "var(--blue-light)", "var(--cyan)"];

  if (pwInput && meter) {
    pwInput.addEventListener("input", function () {
      var v = pwInput.value;
      var level = 0;
      if (v.length >= 8) level = 1;
      if (v.length >= 8 && /[0-9]/.test(v) && /[A-Z]/.test(v)) level = 2;
      if (v.length >= 12 && /[0-9]/.test(v) && /[A-Z]/.test(v) && /[^A-Za-z0-9]/.test(v)) level = 3;
      meter.setAttribute("data-level", level);
      if (strengthLabel) {
        strengthLabel.textContent = v.length > 0 ? STRENGTH_LABELS[level] : "";
        strengthLabel.style.color = v.length > 0 ? STRENGTH_COLORS[level] : "";
      }
    });
  }

  var termsModal = document.getElementById("termsModal");
  var termsScrollBox = document.getElementById("termsScrollBox");
  var acceptTermsBtn = document.getElementById("acceptTermsBtn");
  var declineTermsBtn = document.getElementById("declineTermsBtn");
  var closeTermsBtn = document.getElementById("closeTermsBtn");
  var termsScrollStatus = document.getElementById("termsScrollStatus");
  var statusIcon = document.getElementById("statusIcon");
  var statusText = document.getElementById("statusText");

  function closeTerms() {
    if (termsModal) {
      termsModal.style.display = "none";
      termsModal.setAttribute("aria-hidden", "true");
    }
  }

  if (closeTermsBtn) closeTermsBtn.addEventListener("click", closeTerms);
  if (declineTermsBtn) declineTermsBtn.addEventListener("click", closeTerms);
  if (termsModal) {
    termsModal.addEventListener("click", function (e) {
      if (e.target === termsModal) closeTerms();
    });
  }

  function checkTermsScroll() {
    if (!termsScrollBox || !acceptTermsBtn) return;
    var atBottom = termsScrollBox.scrollTop + termsScrollBox.clientHeight >= termsScrollBox.scrollHeight - 24 ||
      termsScrollBox.scrollHeight <= termsScrollBox.clientHeight + 10;
    if (atBottom) {
      acceptTermsBtn.disabled = false;
      if (termsScrollStatus) {
        termsScrollStatus.classList.add("unlocked");
        if (statusIcon) statusIcon.textContent = "✓";
        if (statusText) statusText.textContent = "Terms reviewed — you may now accept & continue";
      }
    }
  }

  if (termsScrollBox && acceptTermsBtn) {
    termsScrollBox.addEventListener("scroll", checkTermsScroll);
  }

  // Enter key support — triggers createAccountBtn from any form field
  var signupFieldIds = ["firstName", "lastName", "email", "password", "confirm"];
  var createAccountBtn = document.getElementById("createAccountBtn");
  signupFieldIds.forEach(function (id) {
    var el = document.getElementById(id);
    if (el) {
      el.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && createAccountBtn) {
          e.preventDefault();
          createAccountBtn.click();
        }
      });
    }
  });

  if (createAccountBtn) {
    createAccountBtn.addEventListener("click", function (e) {
      var firstNameField = document.getElementById("firstName");
      var lastNameField = document.getElementById("lastName");
      var emailField = document.getElementById("email");
      var passField = document.getElementById("password");
      var confirmField = document.getElementById("confirm");

      var firstValid = firstNameField ? markValid(firstNameField, firstNameField.value.trim().length > 0) : true;
      var lastValid = lastNameField ? markValid(lastNameField, lastNameField.value.trim().length > 0) : true;
      var emailValid = markValid(emailField, EMAIL_RE.test(emailField ? emailField.value : ""));
      var passValid = markValid(passField, passField ? passField.value.length >= 8 : false);
      var confirmValid = markValid(
        confirmField,
        confirmField && passField && confirmField.value === passField.value && confirmField.value.length > 0
      );

      if (firstValid && lastValid && emailValid && passValid && confirmValid) {
        if (termsScrollBox) termsScrollBox.scrollTop = 0;
        if (acceptTermsBtn) acceptTermsBtn.disabled = true;
        if (termsScrollStatus) {
          termsScrollStatus.classList.remove("unlocked");
          if (statusIcon) statusIcon.textContent = "↓";
          if (statusText) statusText.textContent = "Scroll to the bottom to continue";
        }
        if (termsModal) {
          termsModal.style.display = "flex";
          termsModal.setAttribute("aria-hidden", "false");
          setTimeout(checkTermsScroll, 60);
        }
      } else {
        if (e) e.preventDefault();
      }
    });
  }
}

/* -------------------------------------------------------------
   NEW PASSWORD PAGE
   ------------------------------------------------------------- */
function initNewPassword() {
  initInputFocus();
  initLoadReveal();

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
  if (pwInput && meter) {
    pwInput.addEventListener("input", function () {
      var v = pwInput.value;
      var level = 0;
      if (v.length >= 8) level = 1;
      if (v.length >= 8 && /[0-9]/.test(v) && /[A-Z]/.test(v)) level = 2;
      if (v.length >= 12 && /[0-9]/.test(v) && /[A-Z]/.test(v) && /[^A-Za-z0-9]/.test(v)) level = 3;
      meter.setAttribute("data-level", level);
    });
  }
}

/* -------------------------------------------------------------
   PASSWORD VISIBILITY TOGGLE HELPER
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
   BOOTSTRAP AUTH PAGE
   ------------------------------------------------------------- */
function bootAuth() {
  initInputFocus();
  initCustomCursor();
  initPasswordToggles();
  if (document.getElementById("signinForm")) {
    initSignIn();
  }
  if (document.getElementById("signupForm")) {
    initSignUp();
  }
  if (document.getElementById("newPasswordForm")) {
    initNewPassword();
  }
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootAuth);
} else {
  bootAuth();
}

