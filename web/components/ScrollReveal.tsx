"use client";

import { useEffect } from "react";

/**
 * Shows [data-reveal] elements after hydration.
 *
 * The layout script only adds the `js` class before first paint, so the
 * hidden start state does not flash and no-JS visitors still see the content.
 * `is-visible` and the inline animation delay are applied here, after React
 * has hydrated, so they are not a server/client attribute mismatch.
 */
export function ScrollReveal() {
  useEffect(() => {
    const root = document.documentElement;
    if (!root.classList.contains("js")) return;

    const elements = Array.from(document.querySelectorAll("[data-reveal]"));

    const show = (node: Element) => {
      if (!(node instanceof HTMLElement)) return;
      const delay = node.dataset.revealDelay;
      if (delay) node.style.animationDelay = `${delay}ms`;
      node.classList.add("is-visible");
    };

    if (!("IntersectionObserver" in window)) {
      elements.forEach(show);
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          show(entry.target);
          observer.unobserve(entry.target);
        }
      },
      { rootMargin: "0px 0px -10% 0px", threshold: 0.12 },
    );

    elements.forEach((node) => observer.observe(node));
    const timer = window.setTimeout(() => {
      elements.forEach(show);
    }, 2500);

    return () => {
      observer.disconnect();
      window.clearTimeout(timer);
    };
  }, []);

  return null;
}
