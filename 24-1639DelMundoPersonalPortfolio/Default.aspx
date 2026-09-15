<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="progress"></div>
 
<nav class="index-nav" aria-label="Section index">
  <a href="#hero" data-label="Intro"><span>Intro</span></a>
  <a href="#info" data-label="Info"><span>Info</span></a>
  <a href="#stack" data-label="Stack"><span>Stack</span></a>
  <a href="#skills" data-label="Skills"><span>Skills</span></a>
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
        <span class="field-label">Availability</span>
        <p class="placeholder">Looking for any opportunity</p>
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
          <div class="tech-card" data-label="JSON">
            <img src="Images/icons/json.svg" alt="JSON" class="tech-icon" />
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
        <span class="skill-name placeholder">[ add a skill ]</span>
        <div class="skill-track"><div class="skill-fill" data-val="50"></div></div>
        <span class="skill-val">&mdash;</span>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ PROJECTS -->
<section id="projects">
  <div class="wrap-wide">
    <div class="field-label reveal">04 / PROJECTS</div>
    <h2 class="section-title reveal">Selected work</h2>
  </div>
 
  <div class="wrap-wide">
    <div class="bento">
      <!-- P.01 Samson Dental Center -->
      <div class="tile span-7 reveal">
        <div class="tile-thumb">
          <img src="Images/samsondentalcenter.png" alt="Samson Dental Center Web Application" loading="lazy" />
        </div>
        <span class="tile-num">P.01</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <div class="tile-tag">CLINIC PLATFORM / WEB DESIGN</div>
            <h3>Samson Dental Center</h3>
            <p>A modern clinic web application engineered for patient onboarding, digital service catalogs, and online booking workflows. Built with clean responsive design and intuitive medical UX.</p>
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
            <div class="tile-tag">CONVERSATIONAL AI / BOT</div>
            <h3>Review Bot &amp; Clinic Assistant</h3>
            <p>Interactive automated customer service and review triage chatbot integrated with Samson Dental Center. Delivers instant pricing estimates, procedure details, and patient inquiry routing.</p>
          </div>
          <div class="tile-meta">
            <span>Chatbot AI</span><span>Conversational UI</span><span>Smart Triage</span><span>DOM Scripting</span>
          </div>
        </div>
      </div>

      <!-- P.03 AeroStack Payroll System -->
      <div class="tile span-6 reveal">
        <div class="tile-thumb">
          <img src="Images/payroll.png" alt="AeroStack Co. Payroll Executive Dashboard" loading="lazy" />
        </div>
        <span class="tile-num">P.03</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <div class="tile-tag">FINTECH / ENTERPRISE DASHBOARD</div>
            <h3>AeroStack Payroll System</h3>
            <p>Comprehensive HR and payroll analytics dashboard tracking &#8369;408K+ gross disbursements, employee DTR logs, overtime hours, and automated tax/SSS deduction distributions with visual breakdowns.</p>
          </div>
          <div class="tile-meta">
            <span>Enterprise UI</span><span>Data Analytics</span><span>Payroll Engine</span><span>DTR Logging</span>
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
            <div class="tile-tag">ESPORTS / DRAFT SIMULATOR</div>
            <h3>MLBB Mayhem</h3>
            <p>Competitive Mobile Legends: Bang Bang fantasy draft simulator. Features multi-region franchise selection (PH, MENA, Malaysia), 5-role roster assembly, real-time draft status, and team refresh mechanics.</p>
          </div>
          <div class="tile-meta">
            <span>Esports UI</span><span>Draft Simulator</span><span>State Engine</span><span>Interactive Gaming</span>
          </div>
        </div>
      </div>

      <!-- P.05 Tower of Hanoi -->
      <div class="tile span-5 reveal">
        <div class="tile-thumb">
          <img src="Images/tower_of_hanoi.png" alt="Tower of Hanoi Puzzle Game" loading="lazy" />
        </div>
        <span class="tile-num">P.05</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <div class="tile-tag">ALGORITHM / GAME DEV</div>
            <h3>Tower of Hanoi</h3>
            <p>Interactive recursion puzzle with dynamic disk movement, minimum move calculations (2&#8319; &minus; 1), cross-difficulty analytics across 3 to 7 disks, and persistent online competitive leaderboards.</p>
          </div>
          <div class="tile-meta">
            <span>Algorithms</span><span>Game Physics</span><span>Leaderboards</span><span>Performance Stats</span>
          </div>
        </div>
      </div>

      <!-- P.06 CPU Scheduling Calculator -->
      <div class="tile span-7 reveal">
        <div class="tile-thumb">
          <img src="Images/cpu_scheduler.png" alt="CPU Scheduling Calculator" loading="lazy" />
        </div>
        <span class="tile-num">P.06</span>
        <div class="tile-content">
          <div class="tile-body-top">
            <div class="tile-tag">OPERATING SYSTEMS / VISUAL SIMULATOR</div>
            <h3>CPU Scheduling Calculator</h3>
            <p>Algorithm calculation and visualization tool supporting FCFS, SJF, NPP, Priority, SRTF, and Round Robin. Dynamically generates execution timelines, Gantt charts, and exact turnaround/waiting times.</p>
          </div>
          <div class="tile-meta">
            <span>OS Scheduling</span><span>Gantt Chart</span><span>Algorithm Visualizer</span><span>Performance Metrics</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ EDUCATION -->
<section id="education">
  <div class="wrap">
    <div class="field-label reveal">05 / EDUCATION</div>
    <h2 class="section-title reveal">Background</h2>
 
    <div class="edu-list">
      <div class="list-line reveal">
        <span class="yr placeholder">[ YEAR ]</span>
        <div>
          <div class="ttl placeholder">[ Degree / Program ]</div>
          <div class="sub placeholder">[ add relevant coursework or focus ]</div>
        </div>
        <span class="org placeholder">[ School Name ]</span>
      </div>
      <div class="list-line reveal">
        <span class="yr placeholder">[ YEAR ]</span>
        <div>
          <div class="ttl placeholder">[ Certificate / Course ]</div>
          <div class="sub placeholder">[ add details ]</div>
        </div>
        <span class="org placeholder">[ Institution ]</span>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ AWARDS -->
<section id="awards">
  <div class="wrap">
    <div class="field-label reveal">06 / AWARDS</div>
    <h2 class="section-title reveal">Recognition</h2>
 
    <div class="award-list">
      <div class="list-line reveal">
        <span class="yr placeholder">[ YEAR ]</span>
        <div>
          <div class="ttl placeholder">[ Award / Recognition name ]</div>
        </div>
        <span class="org placeholder">[ Issuing organization ]</span>
      </div>
      <div class="list-line reveal">
        <span class="yr placeholder">[ YEAR ]</span>
        <div>
          <div class="ttl placeholder">[ Award / Recognition name ]</div>
        </div>
        <span class="org placeholder">[ Issuing organization ]</span>
      </div>
    </div>
  </div>
</section>
 
<!-- ============================================================ HOBBIES -->
<section id="hobbies">
  <div class="wrap">
    <div class="field-label reveal">07 / HOBBIES</div>
    <h2 class="section-title reveal">Off the clock</h2>
 
    <div class="chip-row reveal">
      <span class="chip real">MLBB Esports</span>
      <span class="chip placeholder">[ add a hobby ]</span>
      <span class="chip placeholder">[ add a hobby ]</span>
      <span class="chip placeholder">[ add a hobby ]</span>
    </div>
  </div>
</section>
 
<!-- ============================================================ CONTACT -->
<section id="contact">
  <div class="wrap">
    <div class="field-label reveal">08 / CONTACT</div>
    <h2 class="contact-cta reveal">Let's build<br>something <span class="accent">structured</span>.</h2>
 
    <div class="contact-links reveal">
      <a href="mailto:you@example.com" class="placeholder">[ email ]</a>
      <a href="#" class="placeholder">[ GitHub ]</a>
      <a href="#" class="placeholder">[ LinkedIn ]</a>
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
