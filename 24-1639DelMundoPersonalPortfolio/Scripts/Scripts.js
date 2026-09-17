/* =============================================================
   KEVS PORTFOLIO — MAIN SCRIPT (Scripts.js)
   Shared by Default.aspx and Profile.aspx
   ============================================================= */

var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/* -------------------------------------------------------------
   SHARED INPUT FOCUS
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
    var duration = typeof options.duration === "number" ? options.duration : 3500;

    var container = getContainer();
    var card = document.createElement("div");
    card.className = "admin-toast-card toast-" + type;

    var iconHtml = icons[type] || icons.info;
    var titleHtml = title ? '<div class="admin-toast-title">' + title + "</div>" : "";

    card.innerHTML =
      '<div class="admin-toast-icon">' + iconHtml + "</div>" +
      '<div class="admin-toast-body">' + titleHtml + '<div class="admin-toast-message">' + msg + "</div></div>" +
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
            onComplete: dismiss,
          }
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
   PORTFOLIO PAGE ANIMATIONS & INTERACTION
   ============================================================= */
function initPortfolio() {
  gsap.registerPlugin(ScrollTrigger);

  /* Top scroll progress bar */
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

  /* Index navigation active indicator */
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
          var link = document.querySelector('.index-nav a[href="#' + sec.id + '"]');
          if (link) link.classList.add("active");
        }
      },
    });
  });

  /* Hero pixel decode scramble */
  var glyphPool = "01".split("");
  function scrambleIn(el, delay) {
    var final = el.textContent;
    if (final.trim() === "") return;
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
        el.textContent = glyphPool[Math.floor(Math.random() * glyphPool.length)];
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

  /* Component-level stagger reveal (stays visible once revealed) */
  document.querySelectorAll(".reveal").forEach(function (el) {
    if (el.closest("#hero")) return;

    gsap.set(el, { opacity: 0, y: 20 });

    var parent = el.parentElement;
    var siblings = Array.from(parent ? parent.children : []).filter(function (c) {
      return c.classList.contains("reveal");
    });
    var idx = siblings.indexOf(el);
    var forwardDelay = idx > 0 ? Math.min(idx * 0.07, 0.35) : 0;

    ScrollTrigger.create({
      trigger: el,
      start: "top 90%",
      once: true,
      onEnter: function () {
        gsap.killTweensOf(el);
        gsap.to(el, {
          opacity: 1,
          y: 0,
          duration: 0.5,
          delay: forwardDelay,
          ease: "power2.out",
        });
      },
    });
  });

  /* Skill bar fill on scroll */
  document.querySelectorAll(".skill-fill").forEach(function (bar) {
    var val = bar.getAttribute("data-val");
    var sec = bar.closest("section");
    ScrollTrigger.create({
      trigger: sec || bar,
      start: "top 88%",
      once: true,
      onEnter: function () {
        gsap.killTweensOf(bar);
        gsap.to(bar, { width: val + "%", duration: 0.8, ease: "power2.out" });
      },
    });
  });

  /* Hero grid parallax pointer interaction */
  var heroGrid = document.getElementById("heroGrid");
  if (!reduceMotion && heroGrid) {
    var heroEl = document.getElementById("hero");
    if (heroEl) {
      heroEl.addEventListener("mousemove", function (e) {
        var x = (e.clientX / window.innerWidth - 0.5) * 14;
        var y = (e.clientY / window.innerHeight - 0.5) * 14;
        gsap.to(heroGrid, { x: x, y: y, duration: 0.6, ease: "power2.out" });
      });
    }
  }

  /* Bento Project tile content hover transition */
  document.querySelectorAll(".tile").forEach(function (tile) {
    tile.addEventListener("mouseenter", function () {
      var content = tile.querySelector(".tile-content");
      if (content) {
        gsap.to(content, { y: 0, duration: 0.3, ease: "power2.out" });
      }
    });
    tile.addEventListener("mouseleave", function () {
      var content = tile.querySelector(".tile-content");
      if (content) {
        gsap.to(content, { y: 45, duration: 0.3, ease: "power2.out" });
      }
    });
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

  // Mousedown snap
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

  document.addEventListener("focusin", function (e) {
    if (e.target && e.target.closest("input, textarea, select, button, [role='button']")) {
      isFocused = true;
      cursor.classList.add("is-focus");
      gsap.to(cursor, { scale: 1.35, duration: 0.22, ease: "power2.out" });
    }
  });

  document.addEventListener("focusout", function (e) {
    if (e.target && e.target.closest("input, textarea, select, button, [role='button']")) {
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
  var currentIndex = -1;
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

  setTimeout(function () {
    decodeTransition(currentText);
  }, 300);

  function decodeTransition(nextText, onComplete) {
    if (animFrame) cancelAnimationFrame(animFrame);
    isDecoding = true;
    var startText = currentText;
    var maxLen = Math.max(startText.length, nextText.length);
    var duration = 1000;
    var startTime = performance.now();

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
            resolvedSpan.textContent = nextText[i] === " " ? "\u00A0" : nextText[i];
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
   ACCOUNT PROFILE PAGE
   ============================================================= */
function initProfile() {
  initInputFocus();

  var pwInput = document.getElementById("txtNewPassword");
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

  if ("scrollRestoration" in history) {
    history.scrollRestoration = "manual";
  }
  window.scrollTo(0, 0);

  // Lock scrolling during loading sequence
  document.body.style.overflow = "hidden";

  var counterObj = { val: 0 };

  // Master GSAP Timeline: Loading count -> Fade Out -> Landing Page Entrance
  var masterTl = gsap.timeline({
    onComplete: function () {
      preloader.classList.add("is-hidden");
      document.body.style.overflow = "";
      if (typeof ScrollTrigger !== "undefined") {
        ScrollTrigger.refresh();
      }
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
   BOOTSTRAP — MAIN & PROFILE
   ============================================================= */
document.addEventListener("DOMContentLoaded", function () {
  initCustomCursor();
  if (document.getElementById("heroName")) {
    if ("scrollRestoration" in history) {
      history.scrollRestoration = "manual";
    }
    window.scrollTo(0, 0);

    initPortfolio();
    initBinaryDecoder();
    initSmoothScroll();
    initPreloader(function () {
      if (window.playHeroEntrance) {
        window.playHeroEntrance();
      }
      if (typeof ScrollTrigger !== "undefined") {
        ScrollTrigger.refresh();
      }
      if (typeof window.__showWelcomeToast === "function") {
        setTimeout(function () {
          window.__showWelcomeToast();
          if (window.history && window.history.replaceState) {
            window.history.replaceState({}, document.title, window.location.pathname);
          }
        }, 400);
      }
    });
  }
  if (document.getElementById("profileForm")) {
    initProfile();
  }
});
