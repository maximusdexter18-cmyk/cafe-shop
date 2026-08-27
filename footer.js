// Shared footer for all customer-facing pages (no build step, classic script).
// Domino's-inspired light theme. Call renderFooter(); after including this file.
function footerStyles() {
  if (document.getElementById('site-footer-style')) return;
  const s = document.createElement('style');
  s.id = 'site-footer-style';
  s.textContent = `
  #site-footer{
    position:relative; z-index:2;
    background:var(--ink);
    color:#fff;
    padding:54px 8vw 40px;
    font-family:'Inter',sans-serif;
  }
  #site-footer .foot-grid{
    max-width:1100px; margin:0 auto;
    display:grid; grid-template-columns:1.4fr 1fr 1fr; gap:40px;
  }
  #site-footer .foot-brand .logo{
    font-family:'Inter',sans-serif; font-weight:800; font-size:1.4rem; letter-spacing:-0.02em; color:#fff; text-transform:uppercase;
  }
  #site-footer .foot-brand p{line-height:1.7; font-size:0.9rem; max-width:34ch; color:#d8d8d8;}
  #site-footer h4{font-weight:800; color:var(--red); font-size:0.82rem; letter-spacing:0.08em; text-transform:uppercase; margin-bottom:14px;}
  #site-footer ul{list-style:none; padding:0; margin:0;}
  #site-footer li{margin-bottom:8px; font-size:0.9rem;}
  #site-footer a{color:#d8d8d8; text-decoration:none; transition:color .2s ease;}
  #site-footer a:hover{color:#fff;}
  #site-footer .socials{display:flex; gap:14px; margin-top:6px;}
  #site-footer .socials a{
    width:38px; height:38px; border-radius:50%; display:flex; align-items:center; justify-content:center;
    background:var(--red); color:#fff; font-size:0.72rem; font-weight:700; letter-spacing:0.04em;
  }
  #site-footer .socials a:hover{background:#fff; color:var(--red);}
  #site-footer .foot-close{
    max-width:1100px; margin:34px auto 0; padding-top:20px;
    border-top:1px solid rgba(255,255,255,0.12);
    font-size:0.8rem; color:#bdbdbd; display:flex; justify-content:space-between; flex-wrap:wrap; gap:10px;
  }
  @media (max-width:720px){ #site-footer .foot-grid{grid-template-columns:1fr 1fr;} }
  @media (max-width:480px){ #site-footer .foot-grid{grid-template-columns:1fr;} }
  `;
  document.head.appendChild(s);
}

function renderFooter() {
  footerStyles();
  let host = document.getElementById('site-footer');
  if (!host) {
    host = document.createElement('div');
    host.id = 'site-footer';
    document.body.appendChild(host);
  }
  host.innerHTML = `
    <div class="foot-grid">
      <div class="foot-brand">
        <div class="logo">Amber & Ash</div>
        <p>Hot coffee, fresh bakes, and a table in minutes. Order ahead or walk in — we've got you.</p>
      </div>
      <div>
        <h4>Visit</h4>
        <ul>
          <li><a href="index.html">Home</a></li>
          <li><a href="menu.html">Menu</a></li>
          <li><a href="order.html">Order</a></li>
          <li><a href="booking.html">Book a Table</a></li>
        </ul>
      </div>
      <div>
        <h4>Contact</h4>
        <ul>
          <li><a href="tel:+911200000000">+91 12000 00000</a></li>
          <li>12 Mill Lane, Bangalore</li>
          <li><a href="mailto:hello@amberandash.cafe">hello@amberandash.cafe</a></li>
        </ul>
        <div class="socials">
          <a href="#" data-social="instagram" aria-label="Instagram">IG</a>
          <a href="#" data-social="facebook" aria-label="Facebook">FB</a>
        </div>
      </div>
    </div>
    <div class="foot-close">
      <span>Amber & Ash — est. 2014</span>
      <span>Open daily, 8am – 9pm</span>
    </div>
  `;
  return host;
}

// Expose for classic (non-module) scripts.
window.renderFooter = renderFooter;
