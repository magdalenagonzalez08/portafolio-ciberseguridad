(function () {
  "use strict";

  var root = document.documentElement;
  var guardado = null;
  try { guardado = localStorage.getItem("tema"); } catch (e) {}
  if (guardado === "dark" || guardado === "light") {
    root.setAttribute("data-theme", guardado);
  }

  function icono(tema) { return tema === "dark" ? "☀" : "☾"; }

  function aplicar(tema) {
    if (tema === "auto") {
      root.removeAttribute("data-theme");
      try { localStorage.removeItem("tema"); } catch (e) {}
    } else {
      root.setAttribute("data-theme", tema);
      try { localStorage.setItem("tema", tema); } catch (e) {}
    }
    var btn = document.querySelector(".theme-toggle");
    if (btn) {
      var actual = root.getAttribute("data-theme") ||
        (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
      btn.textContent = icono(actual);
      btn.setAttribute("aria-label", actual === "dark" ? "Cambiar a modo claro" : "Cambiar a modo oscuro");
    }
  }

  var actual = root.getAttribute("data-theme") ||
    (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");

  document.querySelectorAll(".theme-toggle").forEach(function (btn) {
    btn.textContent = icono(actual);
    btn.setAttribute("aria-label", actual === "dark" ? "Cambiar a modo claro" : "Cambiar a modo oscuro");
    btn.addEventListener("click", function () {
      actual = actual === "dark" ? "light" : "dark";
      aplicar(actual);
    });
  });

  document.querySelectorAll("pre.cmd").forEach(function (pre) {
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "btn btn-ghost no-print";
    btn.textContent = "Copiar";
    btn.style.marginTop = "-.4rem";
    btn.addEventListener("click", function () {
      var code = pre.querySelector("code");
      var texto = code ? code.innerText : pre.innerText;
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(texto).then(function () {
          btn.textContent = "Copiado";
          setTimeout(function () { btn.textContent = "Copiar"; }, 1600);
        });
      }
    });
    pre.insertAdjacentElement("afterend", btn);
  });

  var toc = document.querySelector(".toc ol");
  if (toc && "IntersectionObserver" in window) {
    var enlaces = Array.prototype.slice.call(toc.querySelectorAll("a"));
    var mapa = {};
    enlaces.forEach(function (a) {
      var id = a.getAttribute("href").slice(1);
      var sec = document.getElementById(id);
      if (sec) mapa[id] = a;
    });
    var obs = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (e) {
        var a = mapa[e.target.id];
        if (!a) return;
        if (e.isIntersecting) {
          enlaces.forEach(function (x) { x.style.color = ""; x.style.fontWeight = ""; });
          a.style.color = "var(--accent)";
          a.style.fontWeight = "700";
        }
      });
    }, { rootMargin: "-64px 0px -70% 0px" });
    Object.keys(mapa).forEach(function (id) {
      obs.observe(document.getElementById(id));
    });
  }
})();
