/* =============================================================
   CORPORATE SCRIPT
   Shared by: portfolio.html, sign-in.html, sign-up.html
   Each init() only runs if that page's markup is present, so this
   one file is safe to load everywhere without duplicating logic.
   ============================================================= */

var reduceMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)",
).matches;
var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/* -------------------------------------------------------------
   SHARED HELPERS
   ------------------------------------------------------------- */

/* underline focus state on .input-row (used by sign-in + sign-up) */
function initInputFocus() {
  document.querySelectorAll(".input-row input").forEach(function (input) {
    var row = input.closest(".input-row");
    input.addEventListener("focus", function () {
      row.classList.add("focused");
    });
    input.addEventListener("blur", function () {
      row.classList.remove("focused");
    });
  });
}

/* simple staggered fade/rise-in for elements marked .reveal, no scroll trigger needed
   (used by sign-in + sign-up, which are single-screen pages) */
function initLoadReveal() {
  var els = document.querySelectorAll(".reveal");
  els.forEach(function (el, i) {
    el.style.transition = "opacity .5s ease, transform .5s ease";
    el.style.transitionDelay = i * 0.1 + "s";
  });
  requestAnimationFrame(function () {
    requestAnimationFrame(function () {
      els.forEach(function (el) {
        el.style.opacity = "1";
        el.style.transform = "translateY(0)";
      });
    });
  });
}

/* toggles the .invalid state on a field's wrapper and returns the validity passed in,
   so callers can write: var ok = markValid(field, condition); */
function markValid(field, isValid) {
  field.closest(".field").classList.toggle("invalid", !isValid);
  return isValid;
}

/* =============================================================
   REUSABLE TOAST NOTIFICATION SYSTEM
   ============================================================= */
var Toast = (function () {
  function getContainer() {
    var container =
      document.getElementById("adminToastContainer") ||
      document.querySelector(".admin-toast-container") ||
      document.querySelector(".app-toast-container");
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
    success:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>',
    danger:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    error:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>',
    warning:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    info:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>',
  };

  function show(options) {
    if (typeof options === "string") {
      options = { message: options, type: "success" };
    }
    var msg = options.message || "";
    var title = options.title || "";
    var type = options.type || "success";
    var duration =
      typeof options.duration === "number" ? options.duration : 3500;

    var container = getContainer();
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

    if (closeBtn) closeBtn.addEventListener("click", dismiss);

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
    } else {
      card.style.opacity = "1";
      if (duration > 0) {
        setTimeout(dismiss, duration);
      }
    }

    return { card: card, dismiss: dismiss };
  }

  return {
    show: show,
    success: function (msg, title) {
      return show({ message: msg, title: title || "Success", type: "success" });
    },
    error: function (msg, title) {
      return show({ message: msg, title: title || "Error", type: "error" });
    },
    warning: function (msg, title) {
      return show({ message: msg, title: title || "Warning", type: "warning" });
    },
    info: function (msg, title) {
      return show({ message: msg, title: title || "Info", type: "info" });
    },
  };
})();

window.Toast = Toast;
if (typeof window.AdminToast === "undefined") {
  window.AdminToast = Toast;
}

/* =============================================================
   PORTFOLIO PAGE
   ============================================================= */
function initPortfolio() {
  gsap.registerPlugin(ScrollTrigger);

  /* top scroll progress bar */
  gsap.to("#progress", {
    width: "100%",
    ease: "none",
    scrollTrigger: {
      trigger: document.body,
      start: "top top",
      end: "bottom bottom",
      scrub: 0.3,
    },
  });

  /* index nav active state */
  document.querySelectorAll("section[id]").forEach(function (sec) {
    ScrollTrigger.create({
      trigger: sec,
      start: "top center",
      end: "bottom center",
      onToggle: function (self) {
        if (self.isActive) {
          document.querySelectorAll(".index-nav a").forEach(function (a) {
            a.classList.remove("active");
          });
          var link = document.querySelector(
            '.index-nav a[href="#' + sec.id + '"]',
          );
          if (link) link.classList.add("active");
        }
      },
    });
  });

  /* hero pixel decode */
  var glyphPool = "01".split("");
  function scrambleIn(el, delay) {
    var final = el.textContent;
    if (final.trim() === "") {
      return;
    }
    var obj = { p: 0 };
    gsap.to(obj, {
      p: 1,
      delay: delay,
      duration: 0.6,
      ease: "none",
      onUpdate: function () {
        if (obj.p > 0.85) {
          el.textContent = final;
          return;
        }
        el.textContent =
          glyphPool[Math.floor(Math.random() * glyphPool.length)];
      },
      onComplete: function () {
        el.textContent = final;
      },
    });
  }

  var glyphPool = "01".split("");
  function scrambleIn(el, delay) {
    var final = el.textContent;
    if (final.trim() === "") {
      return;
    }
    var obj = { p: 0 };
    gsap.to(obj, {
      p: 1,
      delay: delay,
      duration: 0.6,
      ease: "none",
      onUpdate: function () {
        if (obj.p > 0.85) {
          el.textContent = final;
          return;
        }
        el.textContent =
          glyphPool[Math.floor(Math.random() * glyphPool.length)];
      },
      onComplete: function () {
        el.textContent = final;
      },
    });
  }

  gsap.set(".hero-role, .hero-meta, .avatar, .hero-kicker, .index-nav", {
    opacity: 0,
    y: 12,
  });

  window.playHeroEntrance = function () {
    var heroGlyphs = document.querySelectorAll("#heroName .glyph");
    heroGlyphs.forEach(function (g, i) {
      scrambleIn(g, 0.05 + i * 0.025);
    });
    gsap.to(".hero-kicker", { opacity: 1, y: 0, duration: 0.5, delay: 0.05 });
    gsap.to(".index-nav", { opacity: 1, y: 0, duration: 0.6, delay: 0.1 });
    gsap.to(".avatar", { opacity: 1, y: 0, duration: 0.7, delay: 0.3 });
    gsap.to(".hero-role", { opacity: 1, y: 0, duration: 0.6, delay: 0.45 });
    gsap.to(".hero-meta", { opacity: 1, y: 0, duration: 0.6, delay: 0.6 });
  };

  /* Component-level stagger reveal & fade out as elements are passed by */
  document.querySelectorAll(".reveal").forEach(function (el) {
    if (el.closest("#hero")) return;

    gsap.set(el, { opacity: 0, y: 20 });

    var parent = el.parentElement;
    var siblings = Array.from(parent.children).filter(function (c) {
      return c.classList.contains("reveal");
    });
    var idx = siblings.indexOf(el);
    var count = siblings.length;

    var forwardDelay = idx > 0 ? Math.min(idx * 0.07, 0.35) : 0;
    var reverseDelay = count > 1 ? Math.min((count - 1 - idx) * 0.07, 0.35) : 0;

    ScrollTrigger.create({
      trigger: el,
      start: "top 88%",
      end: "bottom 12%",
      onEnter: function () {
        gsap.killTweensOf(el);
        gsap.to(el, {
          opacity: 1,
          y: 0,
          duration: 0.45,
          delay: forwardDelay,
          ease: "power2.out",
        });
      },
      onLeave: function () {
        gsap.killTweensOf(el);
        gsap.to(el, {
          opacity: 0,
          duration: 0.3,
          delay: 0,
          ease: "power2.in",
        });
      },
      onEnterBack: function () {
        gsap.killTweensOf(el);
        gsap.to(el, {
          opacity: 1,
          y: 0,
          duration: 0.45,
          delay: reverseDelay,
          ease: "power2.out",
        });
      },
      onLeaveBack: function () {
        gsap.killTweensOf(el);
        gsap.to(el, {
          opacity: 0,
          duration: 0.3,
          delay: 0,
          ease: "power2.in",
        });
      },
    });
  });

  /* hero fade out on scroll down, fade back in on scroll top */
  var heroSec = document.getElementById("hero");
  if (heroSec) {
    var heroEls = heroSec.querySelectorAll(
      ".hero-kicker, .hero-name, .hero-role, .hero-meta, .avatar, .scroll-cue",
    );
    ScrollTrigger.create({
      trigger: heroSec,
      start: "top top",
      end: "bottom 20%",
      onLeave: function () {
        gsap.killTweensOf(heroEls);
        gsap.to(heroEls, {
          opacity: 0,
          duration: 0.3,
          stagger: { each: 0.03, from: "start" },
          ease: "power2.in",
        });
      },
      onEnterBack: function () {
        gsap.killTweensOf(heroEls);
        gsap.to(heroEls, {
          opacity: 1,
          y: 0,
          duration: 0.4,
          stagger: { each: 0.04, from: "end" },
          ease: "power2.out",
        });
      },
    });
  }

  /* skill bar fill & reset on scroll */
  document.querySelectorAll(".skill-fill").forEach(function (bar) {
    var val = bar.getAttribute("data-val");
    var sec = bar.closest("section");
    ScrollTrigger.create({
      trigger: sec || bar,
      start: "top 85%",
      end: "bottom 15%",
      onEnter: function () {
        gsap.killTweensOf(bar);
        gsap.to(bar, { width: val + "%", duration: 0.8, ease: "power2.out" });
      },
      onLeave: function () {
        gsap.killTweensOf(bar);
        gsap.to(bar, { width: "0%", duration: 0.3, ease: "power2.in" });
      },
      onEnterBack: function () {
        gsap.killTweensOf(bar);
        gsap.to(bar, { width: val + "%", duration: 0.8, ease: "power2.out" });
      },
      onLeaveBack: function () {
        gsap.killTweensOf(bar);
        gsap.to(bar, { width: "0%", duration: 0.3, ease: "power2.in" });
      },
    });
  });

  /* subtle hero grid parallax on pointer */
  var heroGrid = document.getElementById("heroGrid");
  if (!reduceMotion && heroGrid) {
    document.getElementById("hero").addEventListener("mousemove", function (e) {
      var x = (e.clientX / window.innerWidth - 0.5) * 14;
      var y = (e.clientY / window.innerHeight - 0.5) * 14;
      gsap.to(heroGrid, { x: x, y: y, duration: 0.6, ease: "power2.out" });
    });
  }

  document.querySelectorAll(".tile").forEach(function (tile) {
    tile.addEventListener("mouseenter", function () {
      gsap.to(tile.querySelector(".tile-content"), {
        y: 0,
        duration: 0.3,
        ease: "power2.out",
      });
    });
    tile.addEventListener("mouseleave", function () {
      gsap.to(tile.querySelector(".tile-content"), {
        y: 45,
        duration: 0.3,
        ease: "power2.out",
      });
    });
  });
}

/* =============================================================
   AUTH DATA STORE (LocalStorage Simulated Persistence)
   ============================================================= */
var AuthStore = {
  USERS_KEY: "kevs_auth_users",
  REQUESTS_KEY: "kevs_password_removal_requests",

  getUsers: function () {
    try {
      var raw = localStorage.getItem(this.USERS_KEY);
      if (!raw) {
        var defaults = [
          {
            name: "Del Mundo, Marc Kevin F.",
            email: "delmundo.marckevin.ferolino@gmail.com",
            password: "Password123!",
            role: "Administrator",
          },
          {
            name: "Demo User",
            email: "you@example.com",
            password: "Password123!",
            role: "User",
          },
        ];
        localStorage.setItem(this.USERS_KEY, JSON.stringify(defaults));
        return defaults;
      }
      return JSON.parse(raw);
    } catch (e) {
      return [];
    }
  },

  saveUsers: function (users) {
    try {
      localStorage.setItem(this.USERS_KEY, JSON.stringify(users));
    } catch (e) {}
  },

  getUser: function (email) {
    var users = this.getUsers();
    email = (email || "").trim().toLowerCase();
    for (var i = 0; i < users.length; i++) {
      if (users[i].email.toLowerCase() === email) return users[i];
    }
    return null;
  },

  addUser: function (name, email, password) {
    var users = this.getUsers();
    var existing = this.getUser(email);
    if (existing) {
      existing.name = name;
      existing.password = password;
      existing.passwordRemoved = false;
    } else {
      users.push({
        name: name,
        email: email.trim().toLowerCase(),
        password: password,
        role: "User",
        createdAt: new Date().toISOString(),
      });
    }
    this.saveUsers(users);
  },

  getRequests: function () {
    try {
      var raw = localStorage.getItem(this.REQUESTS_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      return [];
    }
  },

  saveRequests: function (reqs) {
    try {
      localStorage.setItem(this.REQUESTS_KEY, JSON.stringify(reqs));
    } catch (e) {}
  },

  getRequestForEmail: function (email) {
    var reqs = this.getRequests();
    email = (email || "").trim().toLowerCase();
    for (var i = reqs.length - 1; i >= 0; i--) {
      if (reqs[i].email.toLowerCase() === email) return reqs[i];
    }
    return null;
  },

  requestPasswordRemoval: function (email, reason) {
    email = (email || "").trim().toLowerCase();
    var reqs = this.getRequests();
    for (var i = 0; i < reqs.length; i++) {
      if (
        reqs[i].email.toLowerCase() === email &&
        reqs[i].status === "pending"
      ) {
        return reqs[i];
      }
    }
    var newReq = {
      id: "REQ-" + Date.now().toString(36).toUpperCase(),
      email: email,
      reason: reason || "Forgotten credentials - request removal",
      createdAt: new Date().toLocaleString(),
      status: "pending",
    };
    reqs.unshift(newReq);
    this.saveRequests(reqs);
    return newReq;
  },

  adminRemovePassword: function (email) {
    email = (email || "").trim().toLowerCase();
    var users = this.getUsers();
    for (var i = 0; i < users.length; i++) {
      if (users[i].email.toLowerCase() === email) {
        users[i].password = "";
        users[i].passwordRemoved = true;
        break;
      }
    }
    this.saveUsers(users);

    var reqs = this.getRequests();
    var updated = null;
    for (var j = 0; j < reqs.length; j++) {
      if (reqs[j].email.toLowerCase() === email) {
        reqs[j].status = "password_removed";
        reqs[j].removedAt = new Date().toLocaleString();
        updated = reqs[j];
      }
    }
    this.saveRequests(reqs);
    return updated;
  },

  setNewPassword: function (email, newPassword) {
    email = (email || "").trim().toLowerCase();
    var users = this.getUsers();
    var userFound = false;
    for (var i = 0; i < users.length; i++) {
      if (users[i].email.toLowerCase() === email) {
        users[i].password = newPassword;
        users[i].passwordRemoved = false;
        userFound = true;
        break;
      }
    }
    if (!userFound) {
      users.push({
        name: email.split("@")[0],
        email: email,
        password: newPassword,
        role: "User",
        createdAt: new Date().toISOString(),
      });
    }
    this.saveUsers(users);

    var reqs = this.getRequests();
    for (var j = 0; j < reqs.length; j++) {
      if (reqs[j].email.toLowerCase() === email) {
        reqs[j].status = "completed";
      }
    }
    this.saveRequests(reqs);
  },
};

/* =============================================================
   AUTH — SIGN IN
   ============================================================= */
function initSignIn() {
  initInputFocus();
  initLoadReveal();

  var urlParams = new URLSearchParams(window.location.search);
  var prefilledEmail = urlParams.get("email");
  var emailInput = document.getElementById("email");
  if (prefilledEmail && emailInput) {
    emailInput.value = prefilledEmail;
  }

  // Handle URL notifications via Toast
  if (urlParams.get("registered") === "true") {
    Toast.show({
      title: "ACCOUNT CREATED",
      message: "Account created successfully! Please sign in to continue.",
      type: "success",
      duration: 4000,
    });
  } else if (urlParams.get("reset") === "success") {
    Toast.show({
      title: "PASSWORD UPDATED",
      message: "Your new password has been saved. Please sign in.",
      type: "success",
      duration: 4000,
    });
  }

  // Forgot password modal handlers
  var forgotLink = document.getElementById("forgotPasswordLink");
  var forgotModal = document.getElementById("forgotPasswordModal");
  var closeForgotBtn = document.getElementById("closeForgotBtn");
  var cancelForgotBtn = document.getElementById("cancelForgotBtn");
  var closeForgotStatusBtn = document.getElementById("closeForgotStatusBtn");
  var submitForgotReqBtn = document.getElementById("submitForgotReqBtn");
  var forgotEmailInput = document.getElementById("forgotEmail");
  var forgotReasonInput = document.getElementById("forgotReason");

  var formView = document.getElementById("forgotReqFormView");
  var statusView = document.getElementById("forgotReqStatusView");
  var trackerEmail = document.getElementById("trackerEmail");
  var trackerBadge = document.getElementById("trackerBadge");
  var trackerDetail = document.getElementById("trackerDetail");
  var adminSimCard = document.getElementById("adminSimCard");
  var removedActionView = document.getElementById("passwordRemovedActionView");
  var goToNewPasswordBtn = document.getElementById("goToNewPasswordBtn");
  var adminQuickRemoveBtn = document.getElementById("adminQuickRemoveBtn");

  var currentReqEmail = "";

  function closeForgotModal() {
    if (forgotModal) {
      forgotModal.style.display = "none";
      forgotModal.setAttribute("aria-hidden", "true");
    }
  }

  function showStatusView(email, req) {
    currentReqEmail = email;
    if (formView) formView.style.display = "none";
    if (statusView) statusView.style.display = "block";
    if (trackerEmail) trackerEmail.textContent = email;

    if (req && req.status === "password_removed") {
      if (trackerBadge) {
        trackerBadge.textContent = "PASSWORD REMOVED BY ADMIN";
        trackerBadge.className = "tracker-badge approved";
      }
      if (trackerDetail) {
        trackerDetail.innerHTML =
          "The administrator has verified and <strong>removed the password</strong> for " +
          email +
          ". You can now create a new password.";
      }
      if (adminSimCard) adminSimCard.style.display = "none";
      if (removedActionView) removedActionView.style.display = "block";
      if (goToNewPasswordBtn) {
        goToNewPasswordBtn.href =
          "NewPassword.aspx?email=" + encodeURIComponent(email);
      }
    } else {
      if (trackerBadge) {
        trackerBadge.textContent = "PENDING ADMIN REMOVAL";
        trackerBadge.className = "tracker-badge";
      }
      if (trackerDetail) {
        trackerDetail.innerHTML =
          "A password removal request has been submitted to the administrator for <strong>" +
          email +
          "</strong>. Awaiting administrator action.";
      }
      if (adminSimCard) adminSimCard.style.display = "block";
      if (removedActionView) removedActionView.style.display = "none";
    }
  }

  if (forgotLink) {
    forgotLink.addEventListener("click", function (e) {
      e.preventDefault();
      var currentEntered = emailInput ? emailInput.value.trim() : "";
      if (forgotEmailInput && currentEntered) {
        forgotEmailInput.value = currentEntered;
      }

      if (currentEntered) {
        var existingReq = AuthStore.getRequestForEmail(currentEntered);
        if (existingReq && existingReq.status !== "completed") {
          showStatusView(currentEntered, existingReq);
          if (forgotModal) {
            forgotModal.style.display = "flex";
            forgotModal.setAttribute("aria-hidden", "false");
          }
          return;
        }
      }

      if (formView) formView.style.display = "block";
      if (statusView) statusView.style.display = "none";
      if (forgotModal) {
        forgotModal.style.display = "flex";
        forgotModal.setAttribute("aria-hidden", "false");
      }
    });
  }

  if (closeForgotBtn)
    closeForgotBtn.addEventListener("click", closeForgotModal);
  if (cancelForgotBtn)
    cancelForgotBtn.addEventListener("click", closeForgotModal);
  if (closeForgotStatusBtn)
    closeForgotStatusBtn.addEventListener("click", closeForgotModal);
  if (forgotModal) {
    forgotModal.addEventListener("click", function (e) {
      if (e.target === forgotModal) closeForgotModal();
    });
  }

  if (submitForgotReqBtn) {
    submitForgotReqBtn.addEventListener("click", function () {
      var emailVal = forgotEmailInput ? forgotEmailInput.value.trim() : "";
      if (!EMAIL_RE.test(emailVal)) {
        if (forgotEmailInput) {
          forgotEmailInput.closest(".field").classList.add("invalid");
        }
        return;
      }
      if (forgotEmailInput) {
        forgotEmailInput.closest(".field").classList.remove("invalid");
      }

      var reason = forgotReasonInput ? forgotReasonInput.value.trim() : "";
      var req = AuthStore.requestPasswordRemoval(emailVal, reason);
      showStatusView(emailVal, req);
      Toast.show({
        title: "REQUEST SUBMITTED",
        message: "Password removal request submitted to the administrator.",
        type: "info",
        duration: 3500,
      });
    });
  }

  if (adminQuickRemoveBtn) {
    adminQuickRemoveBtn.addEventListener("click", function () {
      if (!currentReqEmail) return;
      var updated = AuthStore.adminRemovePassword(currentReqEmail);
      showStatusView(currentReqEmail, updated);
      Toast.show({
        title: "ADMIN CLEARANCE",
        message: "Password successfully removed for " + currentReqEmail,
        type: "success",
        duration: 3500,
      });
    });
  }

  var signInBtn = document.getElementById("signInBtn");
  var aspnetForm = document.getElementById("form1");
  if (aspnetForm) {
    aspnetForm.addEventListener("submit", function (e) {
      e.preventDefault();
    });
  }

  function handleSignInAttempt(e) {
    if (e) e.preventDefault();
    var emailField = document.getElementById("email");
    var passField = document.getElementById("password");

    var emailValid = markValid(emailField, EMAIL_RE.test(emailField.value));
    var passValid = markValid(passField, passField.value.length >= 8);

    if (emailValid && passValid) {
      var user = AuthStore.getUser(emailField.value);
      if (user && user.passwordRemoved) {
        Toast.show({
          title: "PASSWORD CLEARED",
          message:
            "The administrator has removed the password for this account. Redirecting to set a new password...",
          type: "warning",
          duration: 3000,
        });
        setTimeout(function () {
          window.location.href =
            "NewPassword.aspx?email=" + encodeURIComponent(emailField.value);
        }, 1200);
        return;
      }

      Toast.show({
        title: "SIGNED IN",
        message:
          "Signed in successfully as " +
          (user ? user.name : emailField.value) +
          "!",
        type: "success",
        duration: 2500,
      });
      setTimeout(function () {
        window.location.href = "../";
      }, 900);
    }
  }

  if (signInBtn) {
    signInBtn.addEventListener("click", handleSignInAttempt);
  }

  var fillMockSigninBtn = document.getElementById("fillMockSigninBtn");
  if (fillMockSigninBtn) {
    fillMockSigninBtn.addEventListener("click", function (e) {
      e.preventDefault();
      var emailField = document.getElementById("email");
      var passField = document.getElementById("password");
      if (emailField) emailField.value = "you@example.com";
      if (passField) passField.value = "Password123!";
    });
  }

  [emailInput, document.getElementById("password")].forEach(function (el) {
    if (el) {
      el.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
          e.preventDefault();
          handleSignInAttempt();
        }
      });
    }
  });
}

/* =============================================================
   AUTH — SIGN UP
   ============================================================= */
function initSignUp() {
  initInputFocus();
  initLoadReveal();

  var aspnetForm = document.getElementById("form1");
  if (aspnetForm) {
    aspnetForm.addEventListener("submit", function (e) {
      e.preventDefault();
    });
  }

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
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

  var termsModal = document.getElementById("termsModal");
  var termsScrollBox = document.getElementById("termsScrollBox");
  var acceptTermsBtn = document.getElementById("acceptTermsBtn");
  var declineTermsBtn = document.getElementById("declineTermsBtn");
  var closeTermsBtn = document.getElementById("closeTermsBtn");
  var termsScrollStatus = document.getElementById("termsScrollStatus");
  var statusIcon = document.getElementById("statusIcon");
  var statusText = document.getElementById("statusText");

  var cachedFormData = null;

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

  // Scroll detection to unlock button
  function checkTermsScroll() {
    if (!termsScrollBox || !acceptTermsBtn) return;
    var atBottom =
      termsScrollBox.scrollTop + termsScrollBox.clientHeight >=
        termsScrollBox.scrollHeight - 24 ||
      termsScrollBox.scrollHeight <= termsScrollBox.clientHeight + 10;
    if (atBottom) {
      acceptTermsBtn.disabled = false;
      if (termsScrollStatus) {
        termsScrollStatus.classList.add("unlocked");
        if (statusIcon) statusIcon.textContent = "✓";
        if (statusText)
          statusText.textContent =
            "Terms reviewed — you may now accept & continue";
      }
    }
  }

  if (termsScrollBox && acceptTermsBtn) {
    termsScrollBox.addEventListener("scroll", checkTermsScroll);
  }

  if (acceptTermsBtn) {
    acceptTermsBtn.addEventListener("click", function () {
      if (acceptTermsBtn.disabled || !cachedFormData) return;
      closeTerms();

      AuthStore.addUser(
        cachedFormData.name,
        cachedFormData.email,
        cachedFormData.password,
      );

      Toast.show({
        title: "ACCOUNT CREATED",
        message: "Account created successfully! Redirecting to sign in...",
        type: "success",
        duration: 2500,
      });

      setTimeout(function () {
        window.location.href =
          "SignIn.aspx?registered=true&email=" +
          encodeURIComponent(cachedFormData.email);
      }, 1200);
    });
  }

  var createAccountBtn = document.getElementById("createAccountBtn");
  function handleSignUpAttempt(e) {
    if (e) e.preventDefault();
    var nameField = document.getElementById("name");
    var emailField = document.getElementById("email");
    var passField = document.getElementById("password");
    var confirmField = document.getElementById("confirm");

    var nameValid = markValid(nameField, nameField.value.trim().length > 0);
    var emailValid = markValid(emailField, EMAIL_RE.test(emailField.value));
    var passValid = markValid(passField, passField.value.length >= 8);
    var confirmValid = markValid(
      confirmField,
      confirmField.value === passField.value && confirmField.value.length > 0,
    );

    if (nameValid && emailValid && passValid && confirmValid) {
      cachedFormData = {
        name: nameField.value.trim(),
        email: emailField.value.trim(),
        password: passField.value,
      };

      if (termsScrollBox) termsScrollBox.scrollTop = 0;
      if (acceptTermsBtn) acceptTermsBtn.disabled = true;
      if (termsScrollStatus) {
        termsScrollStatus.classList.remove("unlocked");
        if (statusIcon) statusIcon.textContent = "↓";
        if (statusText)
          statusText.textContent = "Scroll to the bottom to continue";
      }

      if (termsModal) {
        termsModal.style.display = "flex";
        termsModal.setAttribute("aria-hidden", "false");
        if (termsScrollBox) termsScrollBox.focus();
        setTimeout(checkTermsScroll, 60);
      }
    }
  }

  if (createAccountBtn) {
    createAccountBtn.addEventListener("click", handleSignUpAttempt);
  }

  var fillMockSignupBtn = document.getElementById("fillMockSignupBtn");
  if (fillMockSignupBtn) {
    fillMockSignupBtn.addEventListener("click", function (e) {
      e.preventDefault();
      var nameField = document.getElementById("name");
      var emailField = document.getElementById("email");
      var passField = document.getElementById("password");
      var confirmField = document.getElementById("confirm");
      if (nameField) nameField.value = "Alex Morgan";
      if (emailField) emailField.value = "alex.morgan@example.com";
      if (passField) {
        passField.value = "SecurePass2026!";
        passField.dispatchEvent(new Event("input"));
      }
      if (confirmField) confirmField.value = "SecurePass2026!";
      markValid(nameField, true);
      markValid(emailField, true);
      markValid(passField, true);
      markValid(confirmField, true);
    });
  }

  var nameInput = document.getElementById("name");
  var emailInput = document.getElementById("email");
  var confirmInput = document.getElementById("confirm");
  [nameInput, emailInput, pwInput, confirmInput].forEach(function (el) {
    if (el) {
      el.addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
          e.preventDefault();
          handleSignUpAttempt();
        }
      });
    }
  });
}

/* =============================================================
   AUTH — NEW PASSWORD PAGE
   ============================================================= */
function initNewPassword() {
  initInputFocus();
  initLoadReveal();

  var aspnetForm = document.getElementById("form1");
  if (aspnetForm) {
    aspnetForm.addEventListener("submit", function (e) {
      e.preventDefault();
    });
  }

  var urlParams = new URLSearchParams(window.location.search);
  var emailParam = urlParams.get("email") || "";
  var resetEmailInput = document.getElementById("resetEmail");
  if (resetEmailInput) {
    resetEmailInput.value = emailParam || "you@example.com";
  }

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
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

  var setNewPasswordBtn = document.getElementById("setNewPasswordBtn");
  function handleNewPasswordAttempt(e) {
    if (e) e.preventDefault();
    var emailField = document.getElementById("resetEmail");
    var passField = document.getElementById("password");
    var confirmField = document.getElementById("confirm");

    var emailValid = markValid(emailField, EMAIL_RE.test(emailField.value));
    var passValid = markValid(passField, passField.value.length >= 8);
    var confirmValid = markValid(
      confirmField,
      confirmField.value === passField.value && confirmField.value.length > 0,
    );

    if (emailValid && passValid && confirmValid) {
      AuthStore.setNewPassword(emailField.value, passField.value);

      Toast.show({
        title: "PASSWORD UPDATED",
        message: "New password saved successfully! Redirecting to sign in...",
        type: "success",
        duration: 2500,
      });

      setTimeout(function () {
        window.location.href =
          "SignIn.aspx?reset=success&email=" +
          encodeURIComponent(emailField.value);
      }, 1200);
    }
  }

  if (setNewPasswordBtn) {
    setNewPasswordBtn.addEventListener("click", handleNewPasswordAttempt);
  }

  var fillMockNewPassBtn = document.getElementById("fillMockNewPassBtn");
  if (fillMockNewPassBtn) {
    fillMockNewPassBtn.addEventListener("click", function (e) {
      e.preventDefault();
      var emailField = document.getElementById("resetEmail");
      var passField = document.getElementById("password");
      var confirmField = document.getElementById("confirm");
      if (emailField && !emailField.value) emailField.value = "you@example.com";
      if (passField) {
        passField.value = "BrandNewPass2026!";
        passField.dispatchEvent(new Event("input"));
      }
      if (confirmField) confirmField.value = "BrandNewPass2026!";
      markValid(emailField, true);
      markValid(passField, true);
      markValid(confirmField, true);
    });
  }

  [resetEmailInput, pwInput, document.getElementById("confirm")].forEach(
    function (el) {
      if (el) {
        el.addEventListener("keydown", function (e) {
          if (e.key === "Enter") {
            e.preventDefault();
            handleNewPasswordAttempt();
          }
        });
      }
    },
  );
}

/* =============================================================
   SMOOTH SCROLLING
   ============================================================= */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(function (link) {
    link.addEventListener("click", function (e) {
      var targetId = this.getAttribute("href");
      if (!targetId || targetId === "#") return;
      var targetEl = document.querySelector(targetId);
      if (targetEl) {
        e.preventDefault();
        targetEl.scrollIntoView({ behavior: "smooth", block: "start" });
        if (window.history && window.history.pushState) {
          window.history.pushState(null, null, targetId);
        }
      }
    });
  });

  var scrollCue = document.querySelector(".scroll-cue");
  if (scrollCue) {
    scrollCue.style.cursor = "pointer";
    scrollCue.addEventListener("click", function () {
      var info = document.getElementById("info");
      if (info) {
        info.scrollIntoView({ behavior: "smooth", block: "start" });
      }
    });
  }
}

/* =============================================================
   CUSTOM INVERTING CURSOR
   ============================================================= */
function initCustomCursor() {
  var cursor = document.getElementById("customCursor");
  if (!cursor) return;

  if (window.matchMedia && !window.matchMedia("(pointer: fine)").matches) {
    cursor.style.display = "none";
    return;
  }

  var avatar = document.getElementById("avatar");
  var xTo = gsap.quickTo(cursor, "x", { duration: 0.25, ease: "power2.out" });
  var yTo = gsap.quickTo(cursor, "y", { duration: 0.25, ease: "power2.out" });
  var isVisible = false;
  var isHovered = false;
  var isFocused = false;

  window.addEventListener("mousemove", function (e) {
    xTo(e.clientX);
    yTo(e.clientY);
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

  // Mousedown / active snap
  window.addEventListener("mousedown", function () {
    cursor.classList.add("is-active");
    gsap.to(cursor, {
      scale: isHovered || isFocused ? 1.15 : 0.85,
      duration: 0.15,
      ease: "power2.out",
    });
  });

  window.addEventListener("mouseup", function () {
    cursor.classList.remove("is-active");
    gsap.to(cursor, {
      scale: isHovered || isFocused ? 1.25 : 1,
      duration: 0.18,
      ease: "power2.out",
    });
  });

  // Hover detection on interactive elements
  var interactiveSelector =
    "a, button, input, textarea, select, [role='button'], .btn, .chip, .tile, .tech-card, .nav-link, .brand-mark, .index-nav a, label, [tabindex], .scroll-cue, #heroDynamicName";

  document.addEventListener("mouseover", function (e) {
    if (e.target && e.target.closest(interactiveSelector)) {
      if (!isHovered) {
        isHovered = true;
        cursor.classList.add("is-hover");
        gsap.to(cursor, { scale: 1.35, duration: 0.22, ease: "power2.out" });
      }
    }
  });

  document.addEventListener("mouseout", function (e) {
    if (e.target && e.target.closest(interactiveSelector)) {
      if (!e.relatedTarget || !e.relatedTarget.closest(interactiveSelector)) {
        isHovered = false;
        cursor.classList.remove("is-hover");
        if (!isFocused) {
          gsap.to(cursor, { scale: 1, duration: 0.22, ease: "power2.out" });
        }
      }
    }
  });

  // Active focus on button, input, textarea, etc.
  document.addEventListener("focusin", function (e) {
    if (
      e.target &&
      e.target.closest("input, textarea, select, button, [role='button']")
    ) {
      isFocused = true;
      cursor.classList.add("is-focus");
      gsap.to(cursor, { scale: 1.35, duration: 0.22, ease: "power2.out" });
    }
  });

  document.addEventListener("focusout", function (e) {
    if (
      e.target &&
      e.target.closest("input, textarea, select, button, [role='button']")
    ) {
      isFocused = false;
      cursor.classList.remove("is-focus");
      if (!isHovered) {
        gsap.to(cursor, { scale: 1, duration: 0.22, ease: "power2.out" });
      }
    }
  });

  if (avatar) {
    avatar.addEventListener("mouseenter", function () {
      isHovered = true;
      gsap.to(cursor, { scale: 1.4, duration: 0.22, ease: "power2.out" });
    });
    avatar.addEventListener("mouseleave", function () {
      isHovered = false;
      if (!isFocused) {
        gsap.to(cursor, { scale: 1, duration: 0.22, ease: "power2.out" });
      }
    });
  }
}

/* =============================================================
   HERO BINARY DECODE ROTATOR
   ============================================================= */
function initBinaryDecoder() {
  var container = document.getElementById("heroDynamicName");
  if (!container) return;

  var titles = ["Del Mundo", "Marc Kevin", "Kevs"];
  var currentIndex = -1; // starts from Kevs, next is index 0: Del Mundo
  var isDecoding = false;
  var currentText = container.textContent.trim() || "Kevs";
  var timer = null;
  var animFrame = null;

  function renderResolved(text) {
    container.innerHTML = "";
    for (var i = 0; i < text.length; i++) {
      var span = document.createElement("span");
      span.className = "glyph-char";
      span.textContent = text[i] === " " ? "\u00A0" : text[i];
      container.appendChild(span);
    }
  }

  renderResolved(currentText);

  // Initial binary decode on page load
  setTimeout(function () {
    decodeTransition(currentText);
  }, 300);

  function decodeTransition(nextText, onComplete) {
    if (animFrame) cancelAnimationFrame(animFrame);
    isDecoding = true;
    var startText = currentText;
    var maxLen = Math.max(startText.length, nextText.length);
    var duration = 1000; // ms
    var startTime = performance.now();

    // Safety timeout so decode NEVER gets stuck
    var safetyTimeout = setTimeout(function () {
      if (isDecoding) {
        currentText = nextText;
        renderResolved(nextText);
        isDecoding = false;
        if (onComplete) onComplete();
      }
    }, duration + 300);

    function frame(now) {
      var elapsed = now - startTime;
      var progress = Math.min(elapsed / duration, 1);

      container.innerHTML = "";

      for (var i = 0; i < maxLen; i++) {
        var resolveThreshold = 0.2 + 0.7 * ((i + 1) / maxLen);

        if (progress >= resolveThreshold) {
          if (i < nextText.length) {
            var resolvedSpan = document.createElement("span");
            resolvedSpan.className = "glyph-char";
            resolvedSpan.textContent =
              nextText[i] === " " ? "\u00A0" : nextText[i];
            container.appendChild(resolvedSpan);
          }
        } else {
          var binarySpan = document.createElement("span");
          binarySpan.className = "glyph-binary";
          binarySpan.textContent = Math.random() < 0.5 ? "0" : "1";
          container.appendChild(binarySpan);
        }
      }

      if (progress < 1 && isDecoding) {
        animFrame = requestAnimationFrame(frame);
      } else {
        clearTimeout(safetyTimeout);
        currentText = nextText;
        renderResolved(nextText);
        isDecoding = false;
        if (onComplete) onComplete();
      }
    }

    animFrame = requestAnimationFrame(frame);
  }

  function scheduleNext() {
    if (timer) clearTimeout(timer);
    timer = setTimeout(function () {
      currentIndex = (currentIndex + 1) % titles.length;
      decodeTransition(titles[currentIndex], function () {
        scheduleNext();
      });
    }, 3200);
  }

  setTimeout(scheduleNext, 2600);

  // Prevent desync on tab backgrounding
  document.addEventListener("visibilitychange", function () {
    if (document.hidden) {
      if (timer) clearTimeout(timer);
      if (animFrame) cancelAnimationFrame(animFrame);
      isDecoding = false;
    } else {
      var activeTitle = titles[currentIndex >= 0 ? currentIndex : 0];
      currentText = activeTitle;
      renderResolved(activeTitle);
      scheduleNext();
    }
  });

  container.addEventListener("click", function () {
    if (isDecoding) return;
    if (timer) clearTimeout(timer);
    currentIndex = (currentIndex + 1) % titles.length;
    decodeTransition(titles[currentIndex], function () {
      scheduleNext();
    });
  });
}

/* =============================================================
   AUTH — PROFILE
   ============================================================= */
function initProfile() {
  initInputFocus();

  var avatarUpload = document.getElementById("avatarUpload");
  var avatarPreview = document.getElementById("avatarPreview");
  if (avatarUpload && avatarPreview) {
    avatarUpload.addEventListener("change", function () {
      var file = avatarUpload.files[0];
      if (file) {
        var reader = new FileReader();
        reader.onload = function (e) {
          avatarPreview.src = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    });
  }

  var nameInput = document.getElementById("name");
  var profileHeaderName = document.getElementById("profileHeaderName");
  if (nameInput && profileHeaderName) {
    nameInput.addEventListener("input", function () {
      profileHeaderName.textContent = nameInput.value.trim() || "Your Name";
    });
  }

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
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

  var saveBtn = document.getElementById("saveProfileBtn");
  function handleSave(e) {
    if (e) e.preventDefault();
    var nameField = document.getElementById("name");
    var emailField = document.getElementById("email");
    var passField = document.getElementById("password");
    var confirmField = document.getElementById("confirm");

    var nameValid = markValid(nameField, nameField.value.trim().length > 0);
    var emailValid = markValid(emailField, EMAIL_RE.test(emailField.value));

    var passValid = true;
    if (passField && passField.value.length > 0) {
      passValid = markValid(passField, passField.value.length >= 8);
    }

    var confirmValid = true;
    if (passField && passField.value.length > 0) {
      confirmValid = markValid(
        confirmField,
        confirmField.value === passField.value,
      );
    }

    if (nameValid && emailValid && passValid && confirmValid) {
      var toast = document.getElementById("saveToast");
      if (toast) {
        toast.style.display = "flex";
        toast.style.opacity = "1";
        setTimeout(function () {
          toast.style.opacity = "0";
          setTimeout(function () {
            toast.style.display = "none";
          }, 300);
        }, 3500);
      }
    }
  }

  if (saveBtn) {
    saveBtn.addEventListener("click", handleSave);
  }
  var profileForm = document.getElementById("profileForm");
  if (profileForm) {
    profileForm.addEventListener("submit", handleSave);
  }

  // Admin Security Queue - Password Removal Requests
  function renderAdminRequests() {
    var container = document.getElementById("adminRequestsList");
    if (!container) return;

    var reqs = AuthStore.getRequests();
    var pendingReqs = reqs.filter(function (r) {
      return r.status !== "completed";
    });

    if (pendingReqs.length === 0) {
      container.innerHTML =
        '<div class="empty-requests-msg">' +
        '<span class="pulse-indicator"></span>' +
        "<span>No active password removal requests at this time.</span>" +
        "</div>";
      return;
    }

    container.innerHTML = "";
    pendingReqs.forEach(function (r) {
      var card = document.createElement("div");
      card.className = "admin-req-card";

      var info = document.createElement("div");
      info.className = "admin-req-info";
      info.innerHTML =
        '<div class="admin-req-email">' +
        r.email +
        "</div>" +
        '<div class="admin-req-meta">Requested: ' +
        r.createdAt +
        " &bull; Reason: " +
        (r.reason || "User forgotten credentials") +
        "</div>";

      var actions = document.createElement("div");
      actions.className = "admin-req-actions";

      if (r.status === "password_removed") {
        actions.innerHTML =
          '<span class="admin-status-pill">✓ Password Removed &bull; Awaiting User Reset</span>';
      } else {
        var removeBtn = document.createElement("button");
        removeBtn.type = "button";
        removeBtn.className = "admin-action-remove-btn";
        removeBtn.textContent = "Remove Password";
        removeBtn.addEventListener("click", function () {
          AuthStore.adminRemovePassword(r.email);
          renderAdminRequests();
        });
        actions.appendChild(removeBtn);
      }

      card.appendChild(info);
      card.appendChild(actions);
      container.appendChild(card);
    });
  }

  renderAdminRequests();
}

/* =============================================================
   GEIST PIXEL PRELOADER TIMELINE SEQUENCE
   ============================================================= */
function initPreloader(onComplete) {
  var preloader = document.getElementById("preloader");
  var counter = document.getElementById("preloaderCounter");
  if (!preloader || !counter) {
    if (onComplete) onComplete();
    return;
  }

  // Lock scrolling during loading sequence
  document.body.style.overflow = "hidden";

  var counterObj = { val: 0 };

  // Master GSAP Timeline: Loading count -> Fade Out -> Landing Page Entrance
  var masterTl = gsap.timeline({
    onComplete: function () {
      preloader.classList.add("is-hidden");
      document.body.style.overflow = "";
    },
  });

  // Timeline Step 1: Count up 0 -> 100
  masterTl.to(counterObj, {
    val: 100,
    duration: 1.2,
    ease: "power2.out",
    onUpdate: function () {
      counter.textContent = Math.floor(counterObj.val);
    },
  });

  // Hold count 100 for a fraction of a second
  masterTl.to({}, { duration: 0.1 });

  // Timeline Step 2: Cross-fade preloader out and trigger landing page entrance
  masterTl.to(preloader, {
    opacity: 0,
    duration: 0.6,
    ease: "power2.inOut",
    onStart: function () {
      if (onComplete) onComplete();
    },
  });
}

/* =============================================================
   BOOTSTRAP — detect which page is loaded and init only that
   ============================================================= */
document.addEventListener("DOMContentLoaded", function () {
  initCustomCursor();
  if (document.getElementById("heroName")) {
    initPortfolio();
    initBinaryDecoder();
    initSmoothScroll();
    initPreloader(function () {
      if (window.playHeroEntrance) {
        window.playHeroEntrance();
      }
    });
  }
  if (document.getElementById("signinForm")) {
    initSignIn();
  }
  if (document.getElementById("signupForm")) {
    initSignUp();
  }
  if (document.getElementById("newPasswordForm")) {
    initNewPassword();
  }
  if (document.getElementById("profileForm")) {
    initProfile();
  }
});
