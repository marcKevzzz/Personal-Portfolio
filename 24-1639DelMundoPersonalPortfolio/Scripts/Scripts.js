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

  initScrollTriggersAndReveals();
  initBentoProjectHover();
}

/* Reusable binding for dynamically added / updated DOM elements */
function initScrollTriggersAndReveals() {
  if (typeof ScrollTrigger === "undefined") return;

  // Component-level stagger reveal
  document.querySelectorAll(".reveal").forEach(function (el) {
    if (el.closest("#hero") || el.dataset.revealBound === "true") return;
    el.dataset.revealBound = "true";

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

  // Skill bar fill on scroll
  document.querySelectorAll(".skill-fill").forEach(function (bar) {
    if (bar.dataset.skillBound === "true") return;
    bar.dataset.skillBound = "true";

    var val = bar.getAttribute("data-val") || "0";
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
}

/* Bento Project tile content hover transition */
function initBentoProjectHover() {
  document.querySelectorAll(".tile").forEach(function (tile) {
    if (tile.dataset.hoverBound === "true") return;
    tile.dataset.hoverBound = "true";

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
  var avatar = document.getElementById("avatar");
  if (!cursor) return;

  if (window.matchMedia && !window.matchMedia("(pointer: fine)").matches) {
    cursor.style.display = "none";
    return;
  }

  var mouseX = window.innerWidth / 2;
  var mouseY = window.innerHeight / 2;
  var isHovered = false;
  var isFocused = false;
  var isVisible = false;

  cursor.style.opacity = "0";

  gsap.set(cursor, { xPercent: -50, yPercent: -50 });

  var xTo = gsap.quickTo(cursor, "x", { duration: 0.08, ease: "power3.out" });
  var yTo = gsap.quickTo(cursor, "y", { duration: 0.08, ease: "power3.out" });

  window.addEventListener("mousemove", function (e) {
    mouseX = e.clientX;
    mouseY = e.clientY;
    xTo(mouseX);
    yTo(mouseY);
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
function initBinaryDecoder(customTitles) {
  var container = document.getElementById("heroDynamicName");
  if (!container) return;

  if ((!customTitles || !customTitles.length) && container.getAttribute("data-names")) {
    var raw = container.getAttribute("data-names");
    customTitles = raw.split(",").map(function (s) { return s.trim(); }).filter(Boolean);
  }

  var titles = (customTitles && customTitles.length) ? customTitles : ["Del Mundo", "Marc Kevin", "Kevs"];
  var currentIndex = -1;
  var isDecoding = false;
  var currentText = container.textContent.trim() || titles[titles.length - 1] || "Kevs";
  var timer = null;
  var animFrame = null;

  function renderResolved(text) {
    container.innerHTML = "";
    for (var i = 0; i < text.length; i++) {
      if (text[i] === " ") {
        var spaceSpan = document.createElement("span");
        spaceSpan.className = "glyph-char glyph-space";
        spaceSpan.innerHTML = "&nbsp;";
        container.appendChild(spaceSpan);
        container.appendChild(document.createTextNode(" "));
      } else {
        var span = document.createElement("span");
        span.className = "glyph-char";
        span.textContent = text[i];
        container.appendChild(span);
      }
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
            if (nextText[i] === " ") {
              var resolvedSpace = document.createElement("span");
              resolvedSpace.className = "glyph-char glyph-space";
              resolvedSpace.innerHTML = "&nbsp;";
              container.appendChild(resolvedSpace);
              container.appendChild(document.createTextNode(" "));
            } else {
              var resolvedSpan = document.createElement("span");
              resolvedSpan.className = "glyph-char";
              resolvedSpan.textContent = nextText[i];
              container.appendChild(resolvedSpan);
            }
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
   DYNAMIC DATABASE DATA FETCHING, CACHING & RENDERING
   ============================================================= */
var PORTFOLIO_CACHE_KEY = "portfolio_db_cache_v2";
var PORTFOLIO_CACHE_TTL = 30 * 60 * 1000; // 30 minutes client cache

function escapeHtml(str) {
  if (str === null || str === undefined) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function getCachedPortfolioData() {
  try {
    var raw = sessionStorage.getItem(PORTFOLIO_CACHE_KEY);
    if (!raw) return null;
    var parsed = JSON.parse(raw);
    if (parsed && parsed.timestamp && (Date.now() - parsed.timestamp < PORTFOLIO_CACHE_TTL)) {
      return parsed.data;
    }
  } catch (e) {
    console.warn("[Portfolio Cache] Error reading cache:", e);
  }
  return null;
}

function savePortfolioDataToCache(data) {
  try {
    sessionStorage.setItem(PORTFOLIO_CACHE_KEY, JSON.stringify({
      timestamp: Date.now(),
      data: data
    }));
  } catch (e) {
    console.warn("[Portfolio Cache] Error saving cache:", e);
  }
}

function renderPortfolioData(data) {
  if (!data) return;

  if (data.Profile) {
    renderHero(data.Profile);
    renderBasicInfo(data.Profile);
    renderContact(data.Profile);
  }

  if (data.TechStacks && data.TechStacks.length) {
    renderTechStacks(data.TechStacks);
  }

  if (data.Skills && data.Skills.length) {
    renderSkills(data.Skills);
  }

  if (data.Experiences && data.Experiences.length) {
    renderExperiences(data.Experiences);
  }

  if (data.Projects && data.Projects.length) {
    renderProjects(data.Projects);
  }

  if (data.Educations && data.Educations.length) {
    renderEducations(data.Educations);
  }

  if (data.Awards && data.Awards.length) {
    renderAwards(data.Awards);
  }

  if (data.Hobbies && data.Hobbies.length) {
    renderHobbies(data.Hobbies);
  }

  // Refresh interactive bindings and GSAP triggers for dynamically injected elements
  initScrollTriggersAndReveals();
  initBentoProjectHover();
  if (typeof ScrollTrigger !== "undefined") {
    ScrollTrigger.refresh();
  }
}

function renderHero(profile) {
  if (!profile) return;

  if (profile.HeroSubline) {
    var sublineEl = document.getElementById("heroSubline");
    if (sublineEl) {
      var glyphs = '<span class="accent glyph">/</span>';
      var text = " " + profile.HeroSubline.replace(/^\/+/, "").trim();
      for (var i = 0; i < text.length; i++) {
        glyphs += '<span class="glyph">' + (text[i] === " " ? "\u00A0" : escapeHtml(text[i])) + '</span>';
      }
      sublineEl.innerHTML = glyphs;
    }
  }

  if (profile.RoleSummary) {
    var summaryEl = document.getElementById("heroRoleSummary");
    if (summaryEl) summaryEl.textContent = profile.RoleSummary;
  }

  if (profile.RoleTitle) {
    var roleEl = document.getElementById("heroMetaRole");
    if (roleEl) roleEl.textContent = profile.RoleTitle;
  }

  if (profile.FocusArea) {
    var focusEl = document.getElementById("heroMetaFocus");
    if (focusEl) focusEl.textContent = profile.FocusArea;
  }

  if (profile.BasedIn) {
    var basedEl = document.getElementById("heroMetaBasedIn");
    if (basedEl) basedEl.textContent = profile.BasedIn;
  }

  if (profile.AvatarPath) {
    var avatarImg = document.getElementById("heroAvatarImg");
    if (avatarImg) {
      avatarImg.src = profile.AvatarPath;
      avatarImg.alt = profile.FullName || "Portrait";
    }
  }
}

function renderBasicInfo(profile) {
  if (!profile) return;

  var nameEl = document.getElementById("infoName");
  if (nameEl && profile.FullName) nameEl.textContent = profile.FullName;

  var locEl = document.getElementById("infoLocation");
  if (locEl && profile.LocationAddress) locEl.textContent = profile.LocationAddress;

  var ageEl = document.getElementById("infoAge");
  if (ageEl && profile.Age !== undefined && profile.Age !== null) {
    ageEl.textContent = profile.Age + " years old";
  }

  var expEl = document.getElementById("infoExperience");
  if (expEl && profile.ExperienceYears !== undefined && profile.ExperienceYears !== null) {
    expEl.textContent = profile.ExperienceYears + " years of coding";
  }
}

function renderTechStacks(techStacks) {
  var container = document.getElementById("techStackGroups");
  if (!container || !techStacks || !techStacks.length) return;

  var groupsOrder = ["Frontend", "3D & Motion", "Backend & Database", "Tools & DevOps"];
  var grouped = {};
  groupsOrder.forEach(function (g) { grouped[g] = []; });

  techStacks.forEach(function (item) {
    var g = item.GroupName || "Frontend";
    if (!grouped[g]) grouped[g] = [];
    grouped[g].push(item);
  });

  var html = "";
  groupsOrder.forEach(function (gName) {
    var items = grouped[gName] || [];
    if (!items.length) return;

    html += '<div class="stack-group reveal">' +
      '<div class="stack-group-head"><h4>' + escapeHtml(gName) + '</h4></div>' +
      '<div class="tech-icons-grid">';

    items.forEach(function (item) {
      html += '<div class="tech-card" data-label="' + escapeHtml(item.Label) + '" title="' + escapeHtml(item.Label) + '">' +
        '<img src="' + escapeHtml(item.IconPath) + '" alt="' + escapeHtml(item.Label) + '" class="tech-icon" />' +
      '</div>';
    });

    html += '</div></div>';
  });

  container.innerHTML = html;
}

function renderSkills(skills) {
  var list = document.getElementById("skillsList");
  if (!list || !skills || !skills.length) return;

  var html = "";
  skills.forEach(function (s) {
    var val = s.ProficiencyVal;
    html += '<div class="skill-row reveal">' +
      '<span class="skill-name">' + escapeHtml(s.SkillName) + '</span>' +
      '<div class="skill-track"><div class="skill-fill" data-val="' + val + '"></div></div>' +
      '<span class="skill-val">' + val + '</span>' +
    '</div>';
  });

  list.innerHTML = html;
}

function renderExperiences(experiences) {
  var list = document.getElementById("expList");
  if (!list || !experiences || !experiences.length) return;

  var html = "";
  experiences.forEach(function (exp) {
    var tagsHtml = "";
    if (exp.Tags) {
      var tags = exp.Tags.split(",");
      tags.forEach(function (t) {
        var trimmed = t.trim();
        if (trimmed) {
          tagsHtml += "<span>" + escapeHtml(trimmed) + "</span>";
        }
      });
    }

    html += '<div class="exp-card reveal">' +
      '<div class="exp-header">' +
        '<div class="exp-role-group">' +
          '<h3 class="exp-role">' + escapeHtml(exp.RoleTitle) + '</h3>' +
          '<span class="exp-company">' + escapeHtml(exp.CompanyName) + '</span>' +
        '</div>' +
        '<span class="exp-period">' + escapeHtml(exp.PeriodRange) + '</span>' +
      '</div>' +
      (exp.DescriptionText ? '<p class="exp-desc">' + escapeHtml(exp.DescriptionText) + '</p>' : '') +
      (tagsHtml ? '<div class="exp-tags">' + tagsHtml + '</div>' : '') +
    '</div>';
  });

  list.innerHTML = html;
}

function renderProjects(projects) {
  var bento = document.getElementById("projectsBento");
  if (!bento || !projects || !projects.length) return;

  var totalCount = projects.length;
  var html = "";

  projects.forEach(function (proj, idx) {
    var spanClass = "span-6";

    // If total projects is odd and this is the last project, span the full 12-column row
    if (totalCount % 2 !== 0 && idx === totalCount - 1) {
      spanClass = "span-12";
    } else {
      var rowIndex = Math.floor(idx / 2);
      var isSecondInRow = (idx % 2 === 1);

      // Alternating 2-column row patterns:
      // Even rows (0, 2, 4...): col 7 + col 5
      // Odd rows (1, 3, 5...): col 6 + col 6
      if (rowIndex % 2 === 0) {
        spanClass = isSecondInRow ? "span-5" : "span-7";
      } else {
        spanClass = "span-6";
      }
    }
    var pNum = "P." + (idx + 1 < 10 ? "0" + (idx + 1) : idx + 1);
    var tagsHtml = "";
    if (proj.Tags) {
      var tags = proj.Tags.split(",");
      tags.forEach(function (t) {
        var trimmed = t.trim();
        if (trimmed) {
          tagsHtml += "<span>" + escapeHtml(trimmed) + "</span>";
        }
      });
    }

    var linkHref = proj.ProjectUrl || "#";
    var imgPath = proj.ImagePath || "Assets/Images/samsondentalcenter.png";

    html += '<a href="' + escapeHtml(linkHref) + '" target="_blank" rel="noopener noreferrer" class="tile ' + spanClass + ' reveal">' +
      '<div class="tile-thumb">' +
        '<img src="' + escapeHtml(imgPath) + '" alt="' + escapeHtml(proj.Title) + '" loading="lazy" />' +
      '</div>' +
      '<span class="tile-num">' + pNum + '</span>' +
      '<div class="tile-arrow" title="Open repository in new tab">' +
        '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">' +
          '<line x1="7" y1="17" x2="17" y2="7"></line>' +
          '<polyline points="7 7 17 7 17 17"></polyline>' +
        '</svg>' +
      '</div>' +
      '<div class="tile-content">' +
        '<div class="tile-body-top">' +
          '<h3>' + escapeHtml(proj.Title) + '</h3>' +
        '</div>' +
        '<div class="tile-meta">' + tagsHtml + '</div>' +
      '</div>' +
    '</a>';
  });

  bento.innerHTML = html;
}

function renderEducations(educations) {
  var list = document.getElementById("eduList");
  if (!list || !educations || !educations.length) return;

  var html = "";
  educations.forEach(function (edu) {
    html += '<div class="list-line reveal">' +
      '<span class="yr">' + escapeHtml(edu.YearPeriod) + '</span>' +
      '<div>' +
        '<div class="ttl">' + escapeHtml(edu.Title) + '</div>' +
        '<div class="sub">' + escapeHtml(edu.Subtitle) + '</div>' +
      '</div>' +
      '<span class="org">' + escapeHtml(edu.InstitutionName) + '</span>' +
    '</div>';
  });

  list.innerHTML = html;
}

function renderAwards(awards) {
  var list = document.getElementById("awardList");
  if (!list || !awards || !awards.length) return;

  var html = "";
  awards.forEach(function (award) {
    html += '<div class="list-line reveal">' +
      '<span class="yr">' + escapeHtml(award.AwardYear) + '</span>' +
      '<div>' +
        '<div class="ttl">' + escapeHtml(award.Title) + '</div>' +
        '<div class="sub">' + escapeHtml(award.Subtitle) + '</div>' +
      '</div>' +
      '<span class="org">' + escapeHtml(award.OrganizationName) + '</span>' +
    '</div>';
  });

  list.innerHTML = html;
}

function renderHobbies(hobbies) {
  var list = document.getElementById("hobbiesList");
  if (!list || !hobbies || !hobbies.length) return;

  var html = "";
  hobbies.forEach(function (h) {
    html += '<span class="chip real reveal">' + escapeHtml(h.HobbyName) + '</span>';
  });

  list.innerHTML = html;
}

function renderContact(profile) {
  if (!profile) return;

  var emailLink = document.getElementById("contactEmailLink");
  if (emailLink && profile.Email) {
    emailLink.href = "mailto:" + profile.Email;
  }
  var gitLink = document.getElementById("contactGithubLink");
  if (gitLink && profile.GithubUrl) {
    gitLink.href = profile.GithubUrl;
  }

  var inLink = document.getElementById("contactLinkedinLink");
  if (inLink && profile.LinkedinUrl) {
    inLink.href = profile.LinkedinUrl;
  }
}

function loadPortfolioData(forceRefresh, onDataReady) {
  var cached = !forceRefresh ? getCachedPortfolioData() : null;
  if (cached) {
    renderPortfolioData(cached);
    if (onDataReady) onDataReady(cached, true /* fromCache */);
    return;
  }

  fetch("Default.aspx/GetPortfolioData", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-Requested-With": "XMLHttpRequest"
    },
    body: JSON.stringify({ forceRefresh: !!forceRefresh })
  })
    .then(function (res) {
      if (!res.ok) throw new Error("Network response was not ok: " + res.statusText);
      return res.json();
    })
    .then(function (json) {
      var data = json.d || json;
      if (data) {
        savePortfolioDataToCache(data);
        renderPortfolioData(data);
      }
      if (onDataReady) onDataReady(data, false /* fromCache */);
    })
    .catch(function (err) {
      console.warn("[Portfolio] Failed to fetch data from backend, using fallback DOM:", err);
      if (onDataReady) onDataReady(null, false);
    });
}

// Global utility for manual refresh / cache invalidation
window.refreshPortfolioData = function (force) {
  sessionStorage.removeItem(PORTFOLIO_CACHE_KEY);
  loadPortfolioData(force !== false, function (data) {
    if (data && typeof Toast !== "undefined") {
      Toast.success("Portfolio data updated from database.", "Cache Refreshed");
    }
  });
};

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

  gsap.to(counterObj, {
    val: 100,
    duration: 0.75,
    ease: "power2.inOut",
    onUpdate: function () {
      counter.textContent = Math.floor(counterObj.val);
    },
    onComplete: function () {
      counter.textContent = "100";
      // Smoothly cross-fade preloader overlay out
      gsap.to(preloader, {
        opacity: 0,
        duration: 0.5,
        ease: "power2.inOut",
        delay: 0.05,
        onStart: function () {
          if (onComplete) onComplete();
        },
        onComplete: function () {
          preloader.classList.add("is-hidden");
          document.body.style.overflow = "";
          if (typeof ScrollTrigger !== "undefined") {
            ScrollTrigger.refresh();
          }
        },
      });
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
    initSmoothScroll();
    initPreloader(function () {
      initBinaryDecoder();

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
