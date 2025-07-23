# 🔧 Gerar tabelas no banco
php artisan session:table        # Gera a migração da tabela de sessões
php artisan cache:table          # Gera a migração da tabela de cache

# 🗂 Aplicar todas as migrações (inclusive as novas)
php artisan migrate              # Aplica as migrações (desenvolvimento)
php artisan migrate --force      # Aplica as migrações mesmo em produção ou Docker

# 🔁 Atualizar configurações
php artisan config:clear         # Limpa cache de configuração
php artisan config:cache         # Gera novo cache das configs do .env

# 👨‍💻 Acessar console interativo
php artisan tinker               # Abre REPL para testar lógica e banco direto

# 🔍 Extras úteis
php artisan route:list           # Lista todas as rotas registradas
php artisan db:seed              # Executa os seeders (se necessário)
php artisan optimize             # Otimiza a aplicação (autoload, configs, etc)
