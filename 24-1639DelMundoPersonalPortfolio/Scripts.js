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
   AUTH — SIGN IN
   ============================================================= */
function initSignIn() {
  initInputFocus();
  initLoadReveal();

  document
    .getElementById("signinForm")
    .addEventListener("submit", function (e) {
      e.preventDefault();
      var emailField = document.getElementById("email");
      var passField = document.getElementById("password");

      var emailValid = markValid(emailField, EMAIL_RE.test(emailField.value));
      var passValid = markValid(passField, passField.value.length >= 8);

      if (emailValid && passValid) {
        // Wire this up to your real auth endpoint.
        alert("Sign-in submitted (demo only — connect this to your backend).");
      }
    });
}

/* =============================================================
   AUTH — SIGN UP
   ============================================================= */
function initSignUp() {
  initInputFocus();
  initLoadReveal();

  var pwInput = document.getElementById("password");
  var meter = document.getElementById("strengthMeter");
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

  document
    .getElementById("signupForm")
    .addEventListener("submit", function (e) {
      e.preventDefault();
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
        // Wire this up to your real auth endpoint.
        alert("Sign-up submitted (demo only — connect this to your backend).");
      }
    });
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
      scale: isHovered || isFocused ? 1.6 : 0.8,
      duration: 0.15,
      ease: "power2.out",
    });
  });

  window.addEventListener("mouseup", function () {
    cursor.classList.remove("is-active");
    gsap.to(cursor, {
      scale: isHovered || isFocused ? 2.2 : 1,
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
        gsap.to(cursor, { scale: 2.2, duration: 0.25, ease: "power2.out" });
      }
    }
  });

  document.addEventListener("mouseout", function (e) {
    if (e.target && e.target.closest(interactiveSelector)) {
      if (!e.relatedTarget || !e.relatedTarget.closest(interactiveSelector)) {
        isHovered = false;
        cursor.classList.remove("is-hover");
        if (!isFocused) {
          gsap.to(cursor, { scale: 1, duration: 0.25, ease: "power2.out" });
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
      gsap.to(cursor, { scale: 2.2, duration: 0.25, ease: "power2.out" });
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
        gsap.to(cursor, { scale: 1, duration: 0.25, ease: "power2.out" });
      }
    }
  });

  if (avatar) {
    avatar.addEventListener("mouseenter", function () {
      isHovered = true;
      gsap.to(cursor, { scale: 2.5, duration: 0.25, ease: "power2.out" });
    });
    avatar.addEventListener("mouseleave", function () {
      isHovered = false;
      if (!isFocused) {
        gsap.to(cursor, { scale: 1, duration: 0.25, ease: "power2.out" });
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
        confirmField.value === passField.value
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
  if (document.getElementById("profileForm")) {
    initProfile();
  }
});
