from flask import Flask, request, Response
import subprocess

app = Flask(__name__)

DNSTWIST_BINARY = 'dnstwist'  # Change this for the binary path of dnstwist (if it's installed as a package you can let dnstwist)

@app.route('/dnstwist_algo', methods=['POST'])
def get_dnstwist():
    print(request.data, request.json)  # Print request data for debugging
    domain = request.json['domain']
    try:
        result = subprocess.run([DNSTWIST_BINARY,'--format','list',domain], stdout=subprocess.PIPE, text=True, check=True)
        twisted_domains = result.stdout
        return Response(twisted_domains, mimetype='text/csv')
    except subprocess.CalledProcessError as e:
        return Response(str(e), status=500)
    except Exception as e:
        return Response(str(e), status=400)

@app.route('/dnstwist_resolved', methods=['POST'])
def new_endpoint():
    print(request.data, request.json)
    domain = request.json['domain']
    nameservers = '8.8.8.8,8.8.4.4' # Change this for your own dns servers (using google dns can be faster if your own servers can't handle thousands of dns requests in a short period of time)
    try:
        result = subprocess.run([DNSTWIST_BINARY,'--format','csv','--registered','--useragent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36','--nameservers',nameservers,domain], stdout=subprocess.PIPE, text=True, check=True)
        twisted_domains = result.stdout
        return Response(twisted_domains, mimetype='text/csv')
    except subprocess.CalledProcessError as e:
        return Response(str(e), status=500)
    except Exception as e:
        return Response(str(e), status=400)


@app.route('/test', methods=['GET'])
def test():
    return 'Test Success!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=443, debug=True)
