-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Seed Data
-- ═══════════════════════════════════════════════════════════════

-- ── Categories (tri-lingual) ─────────────────────────────────
INSERT INTO categories (name_en, name_si, name_ta, icon, sort_order) VALUES
  ('Plumbing',          'ජල නල කටයුතු',      'குழாய் பணி',           'plumbing',      1),
  ('Electrical',        'විදුලි කටයුතු',       'மின் வேலை',           'electrical',    2),
  ('Painting',          'පින්තාරු කිරීම',      'வண்ணம் பூசுதல்',       'painting',      3),
  ('Carpentry',         'වඩු වැඩ',            'தச்சு வேலை',          'carpentry',     4),
  ('Masonry',           'ගඩොල් වැඩ',          'கொத்து வேலை',        'masonry',       5),
  ('Cleaning',          'පිරිසිදු කිරීම',      'சுத்தம் செய்தல்',      'cleaning',      6),
  ('Gardening',         'උද්‍යාන කටයුතු',       'தோட்டக்கலை',         'gardening',     7),
  ('AC Repair',         'AC අළුත්වැඩියා',     'ஏசி பழுதுபார்ப்பு',     'ac_repair',     8),
  ('Appliance Repair',  'උපකරණ අළුත්වැඩියා', 'சாதன பழுதுபார்ப்பு',    'appliance',     9),
  ('Moving & Shifting', 'ගෙනයාම',            'இடம் மாற்றம்',         'moving',       10),
  ('Tiling',            'ටයිල් ගැසීම',        'டைலிங்',              'tiling',       11),
  ('Roofing',           'වහල කටයුතු',         'கூரை வேலை',          'roofing',      12),
  ('Welding',           'වෙල්ඩින්',           'வெல்டிங்',            'welding',      13),
  ('Vehicle Repair',    'වාහන අළුත්වැඩියා',   'வாகன பழுதுபார்ப்பு',    'vehicle',      14),
  ('Tutoring',          'ඉගැන්වීම',           'பயிற்றுவித்தல்',        'tutoring',     15),
  ('Beauty & Salon',    'සුන්දරත්ව සේවා',    'அழகு மற்றும் சலூன்',   'beauty',       16),
  ('Photography',       'ඡායාරූපකරණය',      'புகைப்படம் எடுத்தல்',    'photography',  17),
  ('Catering',          'ආහාර සැපයීම',        'உணவு வழங்கல்',        'catering',     18),
  ('Other',             'වෙනත්',             'மற்றவை',              'other',        99);

-- ── Top-Up Packages ──────────────────────────────────────────
INSERT INTO top_up_packages (amount, bonus, label_en, label_si, label_ta, sort_order) VALUES
  (200,    0, 'Rs. 200',               'රු. 200',              'ரூ. 200',               1),
  (500,   25, 'Rs. 500 (+25 bonus)',   'රු. 500 (+25 බෝනස්)',  'ரூ. 500 (+25 போனஸ்)',   2),
  (1000, 100, 'Rs. 1,000 (+100 bonus)','රු. 1,000 (+100 බෝනස්)','ரூ. 1,000 (+100 போனஸ்)', 3),
  (2000, 300, 'Rs. 2,000 (+300 bonus)','රු. 2,000 (+300 බෝනස්)','ரூ. 2,000 (+300 போனஸ்)', 4);

-- ── Subscription Plans ───────────────────────────────────────
INSERT INTO subscription_plans (name, price, period_months, unlock_cap) VALUES
  ('Waddek Pro Pass', 1500.00, 1, 50);
