function odoo-stop --wraps='sudo systemctl stop postgresql.service && sudo systemctl stop odoo' --description 'alias odoo-stop=sudo systemctl stop postgresql.service && sudo systemctl stop odoo'
    sudo systemctl stop postgresql.service && sudo systemctl stop odoo $argv
end
