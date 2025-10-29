#!/bin/bash
# ModSecurity WAF Deployment and Configuration Script

# --- Project Details ---
# [cite_start]Objective: Secure DVWA by deploying and tuning ModSecurity with OWASP CRS. [cite: 10]
# [cite_start]Steps cover installation, configuration, rule deployment, and initial testing. [cite: 10, 191, 382]
# Run this script with: sudo bash setup.sh

echo "--- 1. System Preparation and Core Component Installation ---"
# [cite_start]Update and upgrade the system packages [cite: 16, 17, 18, 19]
sudo apt update && sudo apt upgrade -y

# [cite_start]Install core components: Apache2, MariaDB, PHP, and the ModSecurity module. [cite: 105, 106, 107, 108, 111, 112]
sudo apt install -y apache2 mariadb-server php libapache2-mod-security2

# [cite_start]Install necessary PHP dependencies for DVWA to function. [cite: 133, 136, 137]
sudo apt install -y php-curl php-mbstring php-xml php-zip php-mysqli php-json

# [cite_start]Enable and start services and the ModSecurity Apache module. [cite: 160, 161, 162, 163]
sudo systemctl enable --now apache2
sudo systemctl enable --now mariadb
sudo a2enmod security2

echo "--- 2. ModSecurity WAF Initial Configuration ---"
# [cite_start]Copy the recommended config template to the active config file. [cite: 178, 182]
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# [cite_start]Set the WAF's operating mode to DetectionOnly (Passive Logging) as a safety step. [cite: 179, 180, 181, 183, 184]
sudo sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf

echo "--- 3. Deploy OWASP Core Rule Set (CRS) ---"
# Change to a source directory.
cd /usr/local/src

# [cite_start]Download the latest version of the OWASP CRS. [cite: 196, 217]
sudo git clone https://github.com/coreruleset/coreruleset.git

# [cite_start]Move the downloaded rules into the standard ModSecurity directory. [cite: 205, 217]
sudo mv coreruleset /etc/modsecurity/crs

# [cite_start]Activate the CRS configuration file by copying the example setup. [cite: 216, 217]
sudo cp /etc/modsecurity/crs/crs-setup.conf.example /etc/modsecurity/crs/crs-setup.conf

echo "--- 4. DVWA Deployment and Configuration ---"
# Change to the Apache web root directory.
cd /var/www/html

# [cite_start]Download the Damn Vulnerable Web Application (DVWA). [cite: 221]
sudo git clone https://github.com/digininja/DVWA.git

# [cite_start]Assign the correct permissions to DVWA files for Apache (www-data user). [cite: 221]
sudo chown -R www-data:www-data /var/www/html/DVWA

# [cite_start]Prepare the DVWA config file. [cite: 221]
sudo cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php

# NOTE: You must manually edit /var/www/html/DVWA/config/config.inc.php
# [cite_start]to set \$_DVWA['db_user'] = 'dvwa'; and \$_DVWA['db_password'] = 'password'; [cite: 292, 294, 295]

echo "--- 5. Database Setup (Manual Step) ---"
echo "You must now manually execute the following SQL commands in the MariaDB root shell:"
echo "1. Connect: sudo mysql -u root"
echo "2. Execute:"
[cite_start]echo "    CREATE DATABASE dvwa;" [cite: 262, 271]
[cite_start]echo "    CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'password';" [cite: 272]
[cite_start]echo "    GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';" [cite: 273]
[cite_start]echo "    FLUSH PRIVILEGES;" [cite: 274]
echo "    EXIT;"
read -p "Press Enter after completing the database steps..."

echo "--- 6. Final WAF/Apache Configuration ---"
# [cite_start]Add the IncludeOptional directives to security2.conf to load all rules. [cite: 246, 247, 248]
# This section needs to be manually edited via: sudo nano /etc/apache2/mods-enabled/security2.conf
# Ensure the content is updated to include the necessary rule files:
# <IfModule security2_module>
# SecDataDir /var/cache/modsecurity
# IncludeOptional /etc/modsecurity/modsecurity.conf
# IncludeOptional /etc/modsecurity/crs/crs-setup.conf
# IncludeOptional /etc/modsecurity/crs/coreruleset/rules/*.conf
# </IfModule>
read -p "Press Enter after manually updating /etc/apache2/mods-enabled/security2.conf..."

# [cite_start]Create the custom rules file for project-specific rules and tuning. [cite: 367]
sudo touch /etc/modsecurity/custom_rules.conf
# [cite_start]NOTE: Add your custom rules (e.g., ID 1000001, 1000002, 1000010) and tuning exclusions here. [cite: 370, 374, 377, 431]
echo "IncludeOptional /etc/modsecurity/custom_rules.conf" | sudo tee -a /etc/apache2/mods-enabled/security2.conf

# [cite_start]Restart Apache to apply all changes. [cite: 234, 259, 297]
sudo systemctl restart apache2

echo "--- SETUP COMPLETE ---"
echo "Next steps:"
[cite_start]echo "1. Log into DVWA (http://127.0.0.1/DVWA/) and click 'Create / Reset Database'." [cite: 298, 299]
[cite_start]echo "2. Test the WAF in DetectionOnly mode using attack commands." [cite: 382]
[cite_start]echo "3. When ready, switch to blocking mode: sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf && sudo systemctl restart apache2" [cite: 419]