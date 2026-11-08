// The bar across the top of every game's page: back to all the games, and on to each one.
// One file for all five pages, so the list of games is written once.
(() => {
  const games = [
    ['decay-of-meaning', 'The Decay of Meaning'],
    ['blackpool', 'Blackpool'],
    ['all-or-nothing', 'All or Nothing'],
    ['3-quarters', '3 Quarters'],
    ['matbhed', 'Matbhed'],
  ];
  const here = location.pathname.split('/').filter((p) => p && p !== 'index.html').at(-1);
  const style = document.createElement('style');
  style.textContent = `
    .games-bar { background: #111; color: #e8e8e4; font: 500 14px/1.4 system-ui, -apple-system, "Segoe UI", sans-serif; padding: 10px 16px; display: flex; flex-wrap: wrap; gap: 6px 18px; align-items: baseline; }
    .games-bar a { color: inherit; text-decoration: none; opacity: .72; }
    .games-bar a:hover { opacity: 1; text-decoration: underline; }
    .games-bar .home { opacity: 1; font-weight: 700; margin-right: 6px; }
    .games-bar [aria-current] { opacity: 1; text-decoration: underline; text-underline-offset: 4px; }`;
  const bar = document.createElement('nav');
  bar.className = 'games-bar';
  bar.setAttribute('aria-label', 'All games');
  bar.innerHTML = `<a class="home" href="../">Games by Prayas Abhinav</a>` +
    games.map(([dir, name]) => `<a href="../${dir}/"${dir === here ? ' aria-current="page"' : ''}>${name}</a>`).join('');
  document.head.append(style);
  document.body.prepend(bar);
})();
