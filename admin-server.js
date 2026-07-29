import express from 'express';
import path from 'node:path';
import fs from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const root = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = Number(process.env.PORT || 4173);
const backups = path.join(root, '.admin-backups');

app.use(express.json({ limit: '12mb' }));
app.use('/admin', express.static(path.join(root, 'admin')));
app.use(express.static(root, { index: false }));

const safePage = (name) => {
  if (typeof name !== 'string' || !/^[\w-]+\.html$/i.test(name)) throw new Error('页面名称无效');
  const target = path.resolve(root, name);
  if (path.dirname(target) !== path.resolve(root)) throw new Error('页面路径无效');
  return target;
};

app.get('/api/pages', async (_req, res) => {
  const entries = await fs.readdir(root, { withFileTypes: true });
  const pages = await Promise.all(entries.filter(x => x.isFile() && x.name.toLowerCase().endsWith('.html')).map(async x => {
    const stat = await fs.stat(path.join(root, x.name));
    return { name: x.name, updatedAt: stat.mtime.toISOString() };
  }));
  res.json(pages.sort((a, b) => a.name === 'index.html' ? -1 : b.name === 'index.html' ? 1 : a.name.localeCompare(b.name)));
});

app.get('/api/page/:name', async (req, res) => {
  try { res.type('html').send(await fs.readFile(safePage(req.params.name), 'utf8')); }
  catch (error) { res.status(400).json({ error: error.message }); }
});

app.put('/api/page/:name', async (req, res) => {
  try {
    const target = safePage(req.params.name);
    const html = req.body?.html;
    if (typeof html !== 'string' || !/<html[\s>]/i.test(html) || !/<body[\s>]/i.test(html)) throw new Error('提交的内容不是完整 HTML 页面');
    const old = await fs.readFile(target, 'utf8');
    await fs.mkdir(backups, { recursive: true });
    const stamp = new Date().toISOString().replace(/[:.]/g, '-');
    await fs.writeFile(path.join(backups, `${path.basename(target, '.html')}-${stamp}.html`), old, 'utf8');
    await fs.writeFile(target, html, 'utf8');
    res.json({ ok: true, backup: true });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

app.post('/api/page', async (req, res) => {
  try {
    const target = safePage(req.body?.name);
    if (existsSync(target)) throw new Error('同名页面已存在');
    const title = String(req.body?.title || '新页面').replace(/[<>&]/g, '');
    const html = `<!DOCTYPE html>\n<html lang="zh-CN">\n<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n  <title>${title}</title>\n  <link rel="stylesheet" href="style.css">\n</head>\n<body class="subpage">\n  <div class="glass-overlay" style="opacity:1;pointer-events:auto">\n    <div class="content-container">\n      <header class="header"><h1>${title}</h1><a href="index.html" class="back-btn">← 返回主页</a></header>\n      <div class="bento-grid"><div class="card"><h3>第一张卡片</h3><p>点击右侧编辑内容</p></div></div>\n    </div>\n  </div>\n</body>\n</html>\n`;
    await fs.writeFile(target, html, { encoding: 'utf8', flag: 'wx' });
    res.status(201).json({ ok: true, name: path.basename(target) });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

app.get('/', (_req, res) => res.redirect('/admin/'));
app.listen(port, '127.0.0.1', () => console.log(`博客管理工具：http://127.0.0.1:${port}/admin/`));
