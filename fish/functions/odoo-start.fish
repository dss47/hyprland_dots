function odoo-start --wraps='sudo systemctl start postgresql.service && sudo systemctl start odoo' --description 'alias odoo-start=sudo systemctl start postgresql.service && sudo systemctl start odoo'
    sudo systemctl start postgresql.service && sudo systemctl start odoo $argv
end
