🛡️ ModSecurity WAF Deployment & Tuning Project (OWASP CRS)

A comprehensive project focused on securing a vulnerable web application (Damn Vulnerable Web Application - DVWA) by deploying, configuring, and tuning the ModSecurity Open Source Web Application Firewall (WAF) with the OWASP Core Rule Set (CRS).

This project demonstrates the full WAF operational lifecycle: Passive Logging (DetectionOnly) -> Active Blocking (Enforcement) -> False Positive Tuning.


🎯 Project ObjectiveThe primary goal was to secure DVWA by:
1.Deploying ModSecurity and the OWASP CRS.
2.Transitioning the WAF from a DetectionOnly (logging) mode to an Enforcement (blocking) mode.
3.Performing crucial WAF Tuning to prevent False Positives, ensuring legitimate traffic is not blocked.

🛠️ Key Configuration Steps
The following critical steps were taken to move from a fresh installation to an actively protected, tuned environment:

1. WAF Initial Configuration (Safety First)

   Activation: Copied the template configuration to the active file: sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

   Safe Mode: Set the WAF to passive logging mode to ensure stability before blocking:sudo sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/modsecurity/modsecurity.conf.

2. OWASP CRS Deployment

   Download & Placement: Downloaded the rule set and moved it to the ModSecurity directory:sudo git clone https://github.com/coreruleset/coreruleset.gitsudo mv coreruleset /etc/modsecurity/crs

   CRS Activation: Activated the CRS configuration file, which controls Paranoia Level and thresholds16:sudo cp /etc/modsecurity/crs/coreruleset/crs-setup.conf.example /etc/modsecurity/crs/crs-setup.conf.

3. Custom Rule Addition

Custom ModSecurity rules were added to detect specific attack patterns and scanner user-agents. These were placed in /etc/modsecurity/custom_rules.conf.

i.Example SQLi Rule (ID 1000001): Detects basic SQL injection patterns.
ii.Example XSS Rule (ID 1000002): Detects basic XSS patterns.
iii.Scanner Block Rule (ID 1000010): Blocks known tools like sqlmap and acunetix via their User-Agent.

4. WAF Enforcement Activation:

The WAF was switched to active blocking mode by changing the configuration and restarting Apache:

i.Mode Change: Changed the rule engine directive: SecRuleEngine DetectionOnly -> SecRuleEngine On.

ii.Verification: Re-running the SQLi test confirmed the WAF was actively blocking with an HTTP 403 Forbidden response.

5. False Positive Tuning (Whitelisting)

The final crucial step was to tune the WAF to prevent blocking of legitimate traffic.
