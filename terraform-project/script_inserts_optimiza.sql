USE OPTIMIZA;

-- SELECT * FROM CANDIDATO;
-- SELECT * FROM LAYOUT_VAGAS WHERE id = 1;
-- SELECT * FROM VAGA;

INSERT INTO AREA (nome_area) VALUES ('Financeiro');
INSERT INTO AREA (nome_area) VALUES ('Recursos Humanos');
INSERT INTO AREA (nome_area) VALUES ('TI');
INSERT INTO AREA (nome_area) VALUES ('Marketing');
INSERT INTO AREA (nome_area) VALUES ('Operacoes');

-- ---------------------------------------------------------------LayoutVagas------------------------------------------------------------------------------- 

INSERT INTO LAYOUT_VAGAS (titulo, cargo, experiencia_esperada, nivel_formacao_esperada, curso_esperado, idiomas_esperados) VALUES
-- 1. Estagiário Desenvolvedor
('Estagiário Desenvolvedor', 'estagiario', 'none', 'Ensino_superior_cursando', 'Sistemas de Informação, Ciência da Computação, Engenharia de Software ou áreas correlatas', '{"Português": "C2", "Inglês": "A2"}'),
-- 2. Desenvolvedor Back - Júnior
('Desenvolvedor Back - Júnior', 'analista-jr', '1-3', 'Ensino_superior_cursando', 'Ciência da Computação, Sistemas de Informação, Engenharia ou bootcamp/curso técnico relevante', '{"Português": "C2", "Inglês": "A2"}'),
-- 3. Desenvolvedor Back - Pleno
('Desenvolvedor Back - Pleno', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Ciência da Computação, Sistemas de Informação, Engenharia, pós/curso em arquitetura/distribuição é diferencial', '{"Português": "C2", "Inglês": "B1"}'),
-- 4. Desenvolvedor Back - Sênior
('Desenvolvedor Back - Sênior', 'analista-sr', '3-5', 'Ensino_superior_completo', 'Ciência da Computação, Engenharia de Software, Sistemas de Informação', '{"Português": "C2", "Inglês": "B2"}'),
-- 5. Desenvolvedor Front - Júnior
('Desenvolvedor Front - Júnior', 'analista-jr', '1-3', 'Ensino_superior_cursando', 'Sistemas de Informação, Ciência da Computação, Design/UX (parcialmente) ou bootcamp front-end', '{"Português": "C2", "Inglês": "A2"}'),
-- 6. Desenvolvedor Front - Pleno
('Desenvolvedor Front - Pleno', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Sistemas de Informação, Ciência da Computação, Design UX/UI, bootcamps avançados', '{"Português": "C2", "Inglês": "B1"}'),
-- 7. Desenvolvedor Front - Sênior
('Desenvolvedor Front - Sênior', 'analista-sr', '3-5', 'Ensino_superior_completo', 'Ciência da Computação, Engenharia, Design/UX com especializações', '{"Português": "C2", "Inglês": "B2"}'),
-- 8. Estagiário em Dados
('Estagiário em Dados', 'estagiario', 'none', 'Ensino_superior_cursando', 'Ciência de Dados, Estatística, Engenharia, Análise de Dados; cursos de SQL/Python/R/Power BI são diferenciais', '{"Português": "C2", "Inglês": "A2"}'),
-- 9. Analista de Dados - Júnior
('Analista de Dados - Júnior', 'analista-jr', '1-3', 'Ensino_superior_cursando', 'Estatística, Ciência de Dados, Engenharia, Sistemas de Informação', '{"Português": "C2", "Inglês": "A2"}'),
-- 10. Analista de Dados - Pleno
('Analista de Dados - Pleno', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Ciência de Dados, Estatística, Engenharia, Sistemas de Informação', '{"Português": "C2", "Inglês": "B1"}'),
-- 11. Analista de Dados - Sênior
('Analista de Dados - Sênior', 'analista-sr', '3-5', 'Pos_graduacao', 'Ciência de Dados, Estatística, Engenharia, pós em Data Science/Analytics', '{"Português": "C2", "Inglês": "B2"}'),
-- 12. Estagiário em Marketing / Propaganda
('Estagiário em Marketing / Propaganda', 'estagiario', 'none', 'Ensino_superior_cursando', 'Marketing, Publicidade, Comunicação, Design (com foco digital)', '{"Português": "C2", "Inglês": "A1"}'),
-- 13. Analista de Marketing - Júnior
('Analista de Marketing - Júnior', 'analista-jr', '1-3', 'Ensino_superior_cursando', 'Marketing, Publicidade, Comunicação, cursos em Ads/SEO/Analytics', '{"Português": "C2", "Inglês": "A2"}'),
-- 14. Analista de Marketing - Pleno
('Analista de Marketing - Pleno', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Marketing, Publicidade, Comunicação, Pós em Marketing Digital/Analytics', '{"Português": "C2", "Inglês": "B1"}'),
-- 15. Analista de Marketing - Sênior
('Analista de Marketing - Sênior', 'analista-sr', '3-5', 'Pos_graduacao', 'Marketing, Administração, Comunicação; especializações em Digital/Analytics', '{"Português": "C2", "Inglês": "B2"}'),
-- 16. Analista de Contabilidade
('Analista de Contabilidade', 'analista-jr', '1-3', 'Ensino_superior_completo', 'Ciências Contábeis; cursos em SPED, legislação tributária e Excel/ERP (Totvs, SAP) são diferenciais', '{"Português": "C2", "Inglês": "A1"}'),
-- 17. Assistente Administrativo
('Assistente Administrativo', 'analista-jr', '1-3', 'Ensino_medio_completo', 'Administração, Gestão, cursos em Office (Excel) e rotinas administrativas', '{"Português": "C2"}'),
-- 18. Gestor de Projetos
('Gestor de Projetos', 'manager', '3-5', 'Ensino_superior_completo', 'Administração, Engenharia, Sistemas de Informação; cursos/certificações em gestão de projetos e Agile', '{"Português": "C2", "Inglês": "B1"}'),
-- 19. Estágio em Design Gráfico
('Estágio em Design Gráfico ', 'estagiario', 'none', 'Ensino_superior_cursando', 'Design, Design Gráfico, Comunicação Visual, Publicidade ou áreas afins', '{"Português": "C2"}'),
-- 20. Designer Gráfico – Pleno / Sênior
('Designer Gráfico – Pleno / Sênior', 'analista-pl', '3-5', 'Ensino_superior_completo', 'Design Gráfico, Comunicação Visual ou similar', '{"Português": "C2"}'),
-- 21. UX/UI Designer Pleno
('UX/UI Designer Pleno', 'analista-pl', '1-3', 'Ensino_superior_cursando', 'Design, Design Gráfico, Comunicação Visual ou áreas afins', '{"Português": "C2"}'),
-- 22. UI/UX Designer Sênior
('UI/UX Designer Sênior', 'analista-sr', '5plus', 'Ensino_superior_completo', 'Design, Design de Produto, Comunicação ou similar', '{"Português": "C2", "Inglês": "B1"}'),
-- 23. Mid Level Product Designer
('Mid Level Product Designer', 'analista-pl', '3-5', 'Ensino_superior_completo', 'Design, Design Digital, Comunicação Visual, Interação ou similar', '{"Português": "C2", "Inglês": "A2"}'),
-- 24. Product Owner
('Product Owner', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Administração, Engenharia de Produção, Sistemas de Informação ou áreas relacionadas', '{"Inglês": "B2"}'),
-- 25. Scrum Master
('Scrum Master', 'analista-pl', '1-3', 'Ensino_superior_completo', 'Administração, Sistemas de Informação, Engenharia de Software ou áreas afins', '{"Inglês": "B1"}');