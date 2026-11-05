// DM Realm guide: theme toggle, copy buttons, mobile menu, table of contents highlight.
(function () {
  var root = document.documentElement;

  // Theme: the stored choice wins; otherwise the system's.
  var toggle = document.querySelector(".theme-toggle");
  if (toggle) {
    toggle.addEventListener("click", function () {
      var dark = root.dataset.theme
        ? root.dataset.theme === "dark"
        : !window.matchMedia("(prefers-color-scheme: light)").matches;
      var next = dark ? "light" : "dark";
      root.dataset.theme = next;
      try { localStorage.setItem("dmr-theme", next); } catch (e) {}
    });
  }

  // Copy buttons on every terminal block.
  document.querySelectorAll(".term").forEach(function (term) {
    var pre = term.querySelector("pre");
    if (!pre) return;
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.textContent = "Copy";
    btn.addEventListener("click", function () {
      var text = Array.prototype.map.call(pre.querySelectorAll(".line"), function (l) {
        var clone = l.cloneNode(true);
        clone.querySelectorAll(".prompt, .c").forEach(function (n) { n.remove(); });
        return clone.textContent.trim();
      }).filter(Boolean).join("\n") || pre.textContent.trim();
      var done = function () {
        btn.textContent = "Copied";
        btn.classList.add("copied");
        setTimeout(function () { btn.textContent = "Copy"; btn.classList.remove("copied"); }, 1600);
      };
      if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, function () {});
    });
    term.appendChild(btn);
  });

  // Mobile sidebar.
  var menu = document.querySelector(".sidebar-toggle");
  var sidebar = document.getElementById("sidebar");
  if (menu && sidebar) {
    menu.addEventListener("click", function () {
      var open = sidebar.classList.toggle("open");
      menu.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  // Highlight the section in view in the table of contents.
  var links = document.querySelectorAll(".toc a");
  if (links.length && "IntersectionObserver" in window) {
    var byId = {};
    links.forEach(function (a) { byId[a.getAttribute("href").slice(1)] = a; });
    var visible = {};
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { visible[e.target.id] = e.isIntersecting; });
      var current = null;
      document.querySelectorAll(".prose h2[id]").forEach(function (h) {
        if (visible[h.id] && !current) current = h.id;
      });
      if (current) {
        links.forEach(function (a) { a.classList.remove("active"); });
        byId[current] && byId[current].classList.add("active");
      }
    }, { rootMargin: "-70px 0px -55% 0px" });
    document.querySelectorAll(".prose h2[id]").forEach(function (h) { observer.observe(h); });
  }
})();
