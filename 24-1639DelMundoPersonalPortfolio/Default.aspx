<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- ============================================================ PRELOADER OVERLAY -->
    <div id="preloader" class="preloader-overlay">
      <span id="preloaderCounter" class="preloader-counter">0</span>
    </div>

    <div id="progress"></div>
 
<nav class="index-nav" aria-label="Section index">
  <a href="Profile.aspx" class="nav-profile-btn" aria-label="Account Profile">
    <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="currentColor">
      <rect x="9" y="4" width="6" height="6" />
      <rect x="11" y="10" width="2" height="2" />
      <rect x="6" y="12" width="12" height="3" />
      <rect x="4" y="15" width="16" height="5" />
    </svg>
  </a>
  <a href="#hero" data-label="Intro"><span>Intro</span></a>
  <a href="#info" data-label="Info"><span>Info</span></a>
  <a href="#stack" data-label="Stack"><span>Stack</span></a>
  <a href="#skills" data-label="Skills"><span>Skills</span></a>
  <a href="#experience" data-label="Experience"><span>Experience</span></a>
  <a href="#projects" data-label="Projects"><span>Projects</span></a>
  <a href="#education" data-label="Education"><span>Education</span></a>
  <a href="#awards" data-label="Awards"><span>Awards</span></a>
  <a href="#hobbies" data-label="Hobbies"><span>Hobbies</span></a>
  <a href="#contact" data-label="Contact"><span>Contact</span></a>
</nav>
 
<!-- ============================================================ HERO -->
<section id="hero">
  <div class="grid-bg" id="heroGrid"></div>
  <div class="wrap-wide">
    <div class="hero-inner">
      <div class="hero-left">
        <div class="hero-kicker">PERSONAL PORTFOLIO</div>
        <h1 class="hero-name" id="heroName">
          <span class="hero-name-primary" id="heroDynamicName"><span class="glyph-char">K</span><span class="glyph-char">e</span><span class="glyph-char">v</span><span class="glyph-char">s</span></span>
          <span class="hero-name-sub" id="heroSubline"><span class="accent glyph">/</span><span class="glyph"> </span><span class="glyph">b</span><span class="glyph">u</span><span class="glyph">i</span><span class="glyph">l</span><span class="glyph">d</span><span class="glyph">s</span><span class="glyph"> </span><span class="glyph">i</span><span class="glyph">n</span><span class="glyph">t</span><span class="glyph">e</span><span class="glyph">r</span><span class="glyph">f</span><span class="glyph">a</span><span class="glyph">c</span><span class="glyph">e</span><span class="glyph">s</span></span>
        </h1>
        <p class="hero-role">
          Web developer working across front-end interfaces and the structured data systems behind them &mdash;
          from motion-driven product pages to large-scale JSON datasets.
        </p>
        <div class="hero-meta">
          <div>ROLE<strong>Web Developer</strong></div>
          <div>FOCUS<strong>Interfaces &amp; Data Systems</strong></div>
          <div>BASED IN<strong>Quezon City</strong></div>
        </div>
      </div>
 
      <!-- Replace this div with <img src="your-photo.jpg" alt="Kevs" class="avatar-img"> once a photo is ready -->
      <div class="avatar" id="avatar"><img class="avatar-img" src="Images/pixelart_portrait.png" /></div>
    </div>
  </div>
 
  <div class="scroll-cue"><div class="bar"></div>SCROLL</div>
</section>
 
<!-- ============================================================ BASIC INFO -->
<section id="info">
  <div class="wrap">
    <div class="field-label reveal">01 / BASIC INFO</div>
    <h2 class="section-title reveal">The short version</h2>
 
    <div class="info-grid">
      <div class="info-row reveal">
        <span class="field-label">Name</span>
        <p>Del Mundo, Marc Kevin F.</p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Location</span>
        <p class="placeholder">B2 L6 Emerald St. Novaliches Proper, Q.C.</p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Age</span>
        <p class="placeholder">19 years old</p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Experience</span>
        <p>3 years of coding</p>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ TECH STACK -->
<section id="stack">
  <div class="wrap">
    <div class="field-label reveal">02 / TECH STACK</div>
    <h2 class="section-title reveal">What I build with</h2>
  </div>
 
  <div class="wrap">
    <div class="stack-groups">
      <div class="stack-group reveal">
        <div class="stack-group-head">
          <h4>Frontend</h4>
        </div>
        <div class="tech-icons-grid">
          <div class="tech-card" data-label="HTML5">
            <img src="Images/icons/html5.svg" alt="HTML5" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="CSS3">
            <img src="Images/icons/css3.svg" alt="CSS3" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="JavaScript">
            <img src="Images/icons/js.svg" alt="JavaScript" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="TypeScript">
            <img src="Images/icons/typescript.svg" alt="TypeScript" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Tailwind CSS">
            <img src="Images/icons/tailwindcss.svg" alt="Tailwind CSS" class="tech-icon" />
          </div>
        </div>
      </div>

      <div class="stack-group reveal">
        <div class="stack-group-head">
          <h4>3D &amp; Motion</h4>
        </div>
        <div class="tech-icons-grid">
          <div class="tech-card" data-label="GSAP">
            <img src="Images/icons/gsap.svg" alt="GSAP" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Three.js">
            <img src="Images/icons/threejs.svg" alt="Three.js" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Motion">
            <img src="Images/icons/motion.svg" alt="Motion" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Figma">
            <img src="Images/icons/figma.svg" alt="Figma" class="tech-icon" />
          </div>
        </div>
      </div>

      <div class="stack-group reveal">
        <div class="stack-group-head">
          <h4>Backend &amp; Database</h4>
        </div>
        <div class="tech-icons-grid">
          <div class="tech-card" data-label="C#">
            <img src="Images/icons/csharp.svg" alt="C#" class="tech-icon" />
          </div>
          <div class="tech-card" data-label=".NET Core">
            <img src="Images/icons/netcore.svg" alt=".NET Core" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Node.js">
            <img src="Images/icons/nodejs.svg" alt="Node.js" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="PostgreSQL">
            <img src="Images/icons/postgresql.svg" alt="PostgreSQL" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="MySQL">
            <img src="Images/icons/mysql.svg" alt="MySQL" class="tech-icon" />
          </div>
        </div>
      </div>

      <div class="stack-group reveal">
        <div class="stack-group-head">
          <h4>Tools &amp; DevOps</h4>
        </div>
        <div class="tech-icons-grid">
          <div class="tech-card" data-label="Git">
            <img src="Images/icons/git.svg" alt="Git" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="GitHub">
            <img src="Images/icons/github.svg" alt="GitHub" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="VS Code">
            <img src="Images/icons/vscode.svg" alt="VS Code" class="tech-icon" />
          </div>
          <div class="tech-card" data-label="Visual Studio">
            <img src="Images/icons/visualstudio.svg" alt="Visual Studio" class="tech-icon" />
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ SKILLS -->
<section id="skills">
  <div class="wrap">
    <div class="field-label reveal">03 / SKILLS</div>
    <h2 class="section-title reveal">Where the time goes</h2>
 
    <div class="skills-list">
      <div class="skill-row reveal">
        <span class="skill-name">Frontend Development</span>
        <div class="skill-track"><div class="skill-fill" data-val="92"></div></div>
        <span class="skill-val">92</span>
      </div>
      <div class="skill-row reveal">
        <span class="skill-name">Motion &amp; Interaction</span>
        <div class="skill-track"><div class="skill-fill" data-val="85"></div></div>
        <span class="skill-val">85</span>
      </div>
      <div class="skill-row reveal">
        <span class="skill-name">Data Structuring</span>
        <div class="skill-track"><div class="skill-fill" data-val="88"></div></div>
        <span class="skill-val">88</span>
      </div>
      <div class="skill-row reveal">
        <span class="skill-name">3D Web Integration</span>
        <div class="skill-track"><div class="skill-fill" data-val="70"></div></div>
        <span class="skill-val">70</span>
      </div>
      <div class="skill-row reveal">
        <span class="skill-name placeholder">Problem Solving</span>
        <div class="skill-track"><div class="skill-fill" data-val="85"></div></div>
        <span class="skill-val">85</span>
      </div>
    </div>
  </div>
</section>

<!-- ============================================================ EXPERIENCE -->
<section id="experience">
  <div class="wrap">
    <div class="field-label reveal">04 / EXPERIENCE</div>
    <h2 class="section-title reveal">Where I've worked</h2>

    <div class="exp-list">
      <div class="exp-card reveal">
        <div class="exp-header">
          <div class="exp-role-group">
            <h3 class="exp-role">Front-End Developer</h3>
            <span class="exp-company">Prince IT Solution</span>
          </div>
          <span class="exp-period">AUGUST 2025 &mdash; NOVEMBER 2025</span>
        </div>
        <p class="exp-desc">
          Design and develop responsive web interfaces using React and Tailwind. Collaborate with team members to deliver efficient and visually appealing web solutions.
        </p>
        <div class="exp-tags">
          <span>React</span><span>Tailwind CSS</span><span>UI Development</span><span>Team Collaboration</span>
        </div>
      </div>

      <div class="exp-card reveal">
        <div class="exp-header">
          <div class="exp-role-group">
            <h3 class="exp-role">Full-Stack Developer</h3>
            <span class="exp-company">Teranet Fiber, Q.C.</span>
          </div>
          <span class="exp-period">MARCH 2024 &mdash; APRIL 2024</span>
        </div>
        <p class="exp-desc">
          Assisted in basic web development, backend tasks, and system support. Gained exposure to network operations and technical support workflows.
        </p>
        <div class="exp-tags">
          <span>Web Development</span><span>Backend Tasks</span><span>System Support</span><span>Network Operations</span>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ============================================================ PROJECTS -->
<section id="projects">
  <div class="wrap">
    <div class="field-label reveal">05 / PROJECTS</div>
    <h2 class="section-title reveal">Selected work</h2>
  </div>
 
  <div class="wrap">
    <div class="bento">
      <!-- P.01 Samson Dental Center -->
      <div class="tile span-7 reveal">
        <div class="tile-thumb">
          <img src="Images/samsondentalcenter.png" alt="Samson Dental Center Web Application" loading="lazy" />
        </div>
        <span class="tile-num">P.01</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>Samson Dental Center</h3>
          </div>
          <div class="tile-meta">
            <span>HTML5</span><span>CSS3</span><span>JavaScript</span><span>Healthcare UX</span><span>Responsive</span>
          </div>
        </div>
      </div>

      <!-- P.02 Review Bot -->
      <div class="tile span-5 reveal">
        <div class="tile-thumb">
          <img src="Images/reviewbot.png" alt="Review Bot and Dental Clinic Assistant" loading="lazy" />
        </div>
        <span class="tile-num">P.02</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>Review Bot Assistant</h3>
          </div>
          <div class="tile-meta">
            <span>Chatbot AI</span><span>Conversational UI</span><span>DOM Scripting</span>
          </div>
        </div>
      </div>

      <!-- P.03 CPU Scheduling Calculator -->
      <div class="tile span-6 reveal">
        <div class="tile-thumb">
          <img src="Images/cpu_scheduler.png" alt="CPU Scheduling Calculator" loading="lazy" />
        </div>
        <span class="tile-num">P.03</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>CPU Scheduling Calculator</h3>
          </div>
          <div class="tile-meta">
            <span>OS Scheduling</span><span>Gantt Chart</span><span>Algorithm Visualizer</span>
          </div>
        </div>
      </div>

      <!-- P.04 MLBB Mayhem -->
      <div class="tile span-6 reveal">
        <div class="tile-thumb">
          <img src="Images/mlbb_mayhem.png" alt="MLBB Mayhem Fantasy Draft Simulator" loading="lazy" />
        </div>
        <span class="tile-num">P.04</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>MLBB Mayhem</h3>
          </div>
          <div class="tile-meta">
            <span>Esports UI</span><span>Draft Simulator</span><span>Interactive Gaming</span>
          </div>
        </div>
      </div>

      <!-- P.05 AeroStack Payroll System -->
      <div class="tile span-7 reveal">
        <div class="tile-thumb">
          <img src="Images/payroll.png" alt="AeroStack Co. Payroll Executive Dashboard" loading="lazy" />
        </div>
        <span class="tile-num">P.05</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>AeroStack Payroll System</h3>
          </div>
          <div class="tile-meta">
            <span>Enterprise UI</span><span>Data Analytics</span><span>Payroll Engine</span><span>DTR Logging</span>
          </div>
        </div>
      </div>

      <!-- P.06 Tower of Hanoi -->
      <div class="tile span-5 reveal">
        <div class="tile-thumb">
          <img src="Images/tower_of_hanoi.png" alt="Tower of Hanoi Puzzle Game" loading="lazy" />
        </div>
        <span class="tile-num">P.06</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <h3>Tower of Hanoi</h3>
          </div>
          <div class="tile-meta">
          <span>Game Physics</span><span>Leaderboards</span><span>Performance Stats</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</section>
 
<!-- ============================================================ EDUCATION -->
<section id="education">
  <div class="wrap">
    <div class="field-label reveal">06 / EDUCATION</div>
    <h2 class="section-title reveal">Background</h2>
 
    <div class="edu-list">
      <div class="list-line reveal">
        <span class="yr">2024 &mdash; Present</span>
        <div>
          <div class="ttl">Collegiate Level</div>
          <div class="sub">Bachelor of Science in Information Technology</div>
        </div>
        <span class="org">Quezon City University</span>
      </div>
      <div class="list-line reveal">
        <span class="yr">June &mdash; 2024</span>
        <div>
          <div class="ttl">Senior High School</div>
          <div class="sub">Information and Communication Technology</div>
        </div>
        <span class="org">Gardner College Diliman</span>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ AWARDS -->
<section id="awards">
  <div class="wrap">
    <div class="field-label reveal">07 / AWARDS</div>
    <h2 class="section-title reveal">Recognition</h2>
 
    <div class="award-list">
      <div class="list-line reveal">
        <span class="yr">2026</span>
        <div>
          <div class="ttl">DevCup 2026 Competition</div>
          <div class="sub">2nd Place QCU</div>
        </div>
        <span class="org">Quezon City University</span>
      </div>
      <div class="list-line reveal">
        <span class="yr">2025</span>
        <div>
          <div class="ttl">Code Quest 2025</div>
          <div class="sub">Certificate of Participation</div>
        </div>
        <span class="org">Quezon City University</span>
      </div>
      <div class="list-line reveal">
        <span class="yr">2025</span>
        <div>
          <div class="ttl">AWS Learning Club QCU</div>
          <div class="sub">Operational Member</div>
        </div>
        <span class="org">AWS Learning Club</span>
      </div>
      <div class="list-line reveal">
        <span class="yr">2024</span>
        <div>
          <div class="ttl">The Hour of Code</div>
          <div class="sub">Certificate of Completion</div>
        </div>
        <span class="org">ASEAN Youth Organization</span>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ HOBBIES -->
<section id="hobbies">
  <div class="wrap">
    <div class="field-label reveal">08 / HOBBIES</div>
    <h2 class="section-title reveal">Off the clock</h2>
 
    <div class="chip-row">
      <span class="chip real reveal">Reading Manhwa, Manhua &amp; Manga</span>
      <span class="chip real reveal">Online Games</span>
      <span class="chip real reveal">Coding</span>
      <span class="chip real reveal">Basketball</span>
    </div>
  </div>
</section>
 
<!-- ============================================================ CONTACT -->
<section id="contact">
  <div class="wrap">
    <div class="field-label reveal">09 / CONTACT</div>
    <h2 class="contact-cta reveal">Let's build<br>something <span class="accent">structured</span>.</h2>
 
    <div class="contact-links">
      <a href="mailto:delmundo.marckevin.ferolino@gmail.com" class="reveal">[ Email ]</a>
      <a href="https://github.com/marcKevzzz" class="reveal">[ Github ]</a>
      <a href="https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436/" class="reveal">[ LinkedIn ]</a>
    </div>
  </div>
</section>
 
<footer>
  <div class="wrap" style="display:flex; justify-content:space-between; width:100%;">
    <span>KEVS &mdash; 2026</span>
    <span>BUILT WITH GEIST</span>
  </div>
</footer>
 

</asp:Content>
