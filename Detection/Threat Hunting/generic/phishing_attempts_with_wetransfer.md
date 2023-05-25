## Phishing with Wetransfer
ref: https://twitter.com/mthcht/status/1658853848323182597?s=20

WeTransfer is a popular file-sharing service often used by malicious actors for phishing campaigns due to its legitimate reputation and widespread use even within some enterprises to share files🤦‍♂️

How can you detect collection and data exfiltration with wetransfer in your proxy logs ?

### Data Exfiltration Indicators:

- Regular browsing to `wetransfer.com` entails periodic GET requests to `https://backgrounds.wetransfer.net/creator/wepresent-*` approximately every 40 seconds.
- The process of uploading files begins with email confirmation, which involves a POST request to `https://wetransfer.com/api/v4/transfers/email`.
- Further file manipulations will lead to requests to `https://wetransfer.com/api/v4/transfers/*`
- Upon email confirmation, file uploads proceed via a backend API URL `https://e-10220.adzerk.net/api/v2`. However, note that this URL is subject to frequent changes.

### Data Collection Indicators:

- The targeted user will get an email from WeTransfer containing a single download link
- The download link follow the patterns:
  - `https://wetransfer.com/downloads/*`
  - `https://we.tl/t-*`
  - (Each link ends with a unique id)

So, for comprehensive detection of exfiltration via the WeTransfer UI, generic data exfiltration detection techniques (monitoring outbound data volume) is good however, for smaller files and to focus on WeTransfer, the relevant detection is to hunt for POST requests to **`*Wetransfer.com/api/v4/transfers/*`**
and for collection, hunt for requests to **`*wetransfer.com/downloads/*`** or **`we.tl/t-*`**
