function odoo-restart --wraps='sudo systemctl restart odoo' --description 'alias odoo-restart=sudo systemctl restart odoo'
    sudo systemctl restart odoo $argv
end
