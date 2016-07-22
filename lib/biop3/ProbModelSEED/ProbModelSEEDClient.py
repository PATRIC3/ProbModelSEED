############################################################
#
# Autogenerated by the KBase type compiler -
# any changes made here will be overwritten
#
############################################################

try:
    import json as _json
except ImportError:
    import sys
    sys.path.append('simplejson-2.3.3')
    import simplejson as _json

import requests as _requests
import urlparse as _urlparse
import random as _random
import base64 as _base64
from ConfigParser import ConfigParser as _ConfigParser
import os as _os

_CT = 'content-type'
_AJ = 'application/json'
_URL_SCHEME = frozenset(['http', 'https'])


def _get_token(user_id, password,
               auth_svc='https://nexus.api.globusonline.org/goauth/token?' +
                        'grant_type=client_credentials'):
    # This is bandaid helper function until we get a full
    # KBase python auth client released
    auth = _base64.encodestring(user_id + ':' + password)
    headers = {'Authorization': 'Basic ' + auth}
    ret = _requests.get(auth_svc, headers=headers, allow_redirects=True)
    status = ret.status_code
    if status >= 200 and status <= 299:
        tok = _json.loads(ret.text)
    elif status == 403:
        raise Exception('Authentication failed: Bad user_id/password ' +
                        'combination for user %s' % (user_id))
    else:
        raise Exception(ret.text)
    return tok['access_token']


def _read_rcfile(file=_os.environ['HOME'] + '/.authrc'):  # @ReservedAssignment
    # Another bandaid to read in the ~/.authrc file if one is present
    authdata = None
    if _os.path.exists(file):
        try:
            with open(file) as authrc:
                rawdata = _json.load(authrc)
                # strip down whatever we read to only what is legit
                authdata = {x: rawdata.get(x) for x in (
                    'user_id', 'token', 'client_secret', 'keyfile',
                    'keyfile_passphrase', 'password')}
        except Exception, e:
            print "Error while reading authrc file %s: %s" % (file, e)
    return authdata


def _read_inifile(file=_os.environ.get(  # @ReservedAssignment
                  'KB_DEPLOYMENT_CONFIG', _os.environ['HOME'] +
                  '/.kbase_config')):
    # Another bandaid to read in the ~/.kbase_config file if one is present
    authdata = None
    if _os.path.exists(file):
        try:
            config = _ConfigParser()
            config.read(file)
            # strip down whatever we read to only what is legit
            authdata = {x: config.get('authentication', x)
                        if config.has_option('authentication', x)
                        else None for x in ('user_id', 'token',
                                            'client_secret', 'keyfile',
                                            'keyfile_passphrase', 'password')}
        except Exception, e:
            print "Error while reading INI file %s: %s" % (file, e)
    return authdata


class ServerError(Exception):

    def __init__(self, name, code, message, data=None, error=None):
        self.name = name
        self.code = code
        self.message = '' if message is None else message
        self.data = data or error or ''
        # data = JSON RPC 2.0, error = 1.1

    def __str__(self):
        return self.name + ': ' + str(self.code) + '. ' + self.message + \
            '\n' + self.data


class _JSONObjectEncoder(_json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, set):
            return list(obj)
        if isinstance(obj, frozenset):
            return list(obj)
        return _json.JSONEncoder.default(self, obj)


class ProbModelSEED(object):

    def __init__(self, url=None, timeout=30 * 60, user_id=None,
                 password=None, token=None, ignore_authrc=False,
                 trust_all_ssl_certificates=False):
        if url is None:
            raise ValueError('A url is required')
        scheme, _, _, _, _, _ = _urlparse.urlparse(url)
        if scheme not in _URL_SCHEME:
            raise ValueError(url + " isn't a valid http url")
        self.url = url
        self.timeout = int(timeout)
        self._headers = dict()
        self.trust_all_ssl_certificates = trust_all_ssl_certificates
        # token overrides user_id and password
        if token is not None:
            self._headers['AUTHORIZATION'] = token
        elif user_id is not None and password is not None:
            self._headers['AUTHORIZATION'] = _get_token(user_id, password)
        elif 'KB_AUTH_TOKEN' in _os.environ:
            self._headers['AUTHORIZATION'] = _os.environ.get('KB_AUTH_TOKEN')
        elif not ignore_authrc:
            authdata = _read_inifile()
            if authdata is None:
                authdata = _read_rcfile()
            if authdata is not None:
                if authdata.get('token') is not None:
                    self._headers['AUTHORIZATION'] = authdata['token']
                elif(authdata.get('user_id') is not None
                     and authdata.get('password') is not None):
                    self._headers['AUTHORIZATION'] = _get_token(
                        authdata['user_id'], authdata['password'])
        if self.timeout < 1:
            raise ValueError('Timeout value must be at least 1 second')

    def _call(self, method, params):
        arg_hash = {'method': method,
                    'params': params,
                    'version': '1.1',
                    'id': str(_random.random())[2:]
                    }

        body = _json.dumps(arg_hash, cls=_JSONObjectEncoder)
        ret = _requests.post(self.url, data=body, headers=self._headers,
                             timeout=self.timeout,
                             verify=not self.trust_all_ssl_certificates)
        if ret.status_code == _requests.codes.server_error:
            if _CT in ret.headers and ret.headers[_CT] == _AJ:
                err = _json.loads(ret.text)
                if 'error' in err:
                    raise ServerError(**err['error'])
                else:
                    raise ServerError('Unknown', 0, ret.text)
            else:
                raise ServerError('Unknown', 0, ret.text)
        if ret.status_code != _requests.codes.OK:
            ret.raise_for_status()
        resp = _json.loads(ret.text)
        if 'result' not in resp:
            raise ServerError('Unknown', 0, 'An unknown server error occurred')
        return resp['result']

    def list_gapfill_solutions(self, input):
        resp = self._call('ProbModelSEED.list_gapfill_solutions',
                          [input])
        return resp[0]

    def manage_gapfill_solutions(self, input):
        resp = self._call('ProbModelSEED.manage_gapfill_solutions',
                          [input])
        return resp[0]

    def list_fba_studies(self, input):
        resp = self._call('ProbModelSEED.list_fba_studies',
                          [input])
        return resp[0]

    def delete_fba_studies(self, input):
        resp = self._call('ProbModelSEED.delete_fba_studies',
                          [input])
        return resp[0]

    def export_model(self, input):
        resp = self._call('ProbModelSEED.export_model',
                          [input])
        return resp[0]

    def export_media(self, input):
        resp = self._call('ProbModelSEED.export_media',
                          [input])
        return resp[0]

    def get_model(self, input):
        resp = self._call('ProbModelSEED.get_model',
                          [input])
        return resp[0]

    def delete_model(self, input):
        resp = self._call('ProbModelSEED.delete_model',
                          [input])
        return resp[0]

    def list_models(self, input):
        resp = self._call('ProbModelSEED.list_models',
                          [input])
        return resp[0]

    def copy_model(self, input):
        resp = self._call('ProbModelSEED.copy_model',
                          [input])
        return resp[0]

    def copy_genome(self, input):
        resp = self._call('ProbModelSEED.copy_genome',
                          [input])
        return resp[0]

    def list_model_edits(self, input):
        resp = self._call('ProbModelSEED.list_model_edits',
                          [input])
        return resp[0]

    def manage_model_edits(self, input):
        resp = self._call('ProbModelSEED.manage_model_edits',
                          [input])
        return resp[0]

    def get_feature(self, input):
        resp = self._call('ProbModelSEED.get_feature',
                          [input])
        return resp[0]

    def save_feature_function(self, input):
        self._call('ProbModelSEED.save_feature_function',
                   [input])

    def compare_regions(self, input):
        resp = self._call('ProbModelSEED.compare_regions',
                          [input])
        return resp[0]

    def plant_annotation_overview(self, input):
        resp = self._call('ProbModelSEED.plant_annotation_overview',
                          [input])
        return resp[0]

    def create_genome_from_shock(self, input):
        resp = self._call('ProbModelSEED.create_genome_from_shock',
                          [input])
        return resp[0]

    def plant_pipeline(self, input):
        resp = self._call('ProbModelSEED.plant_pipeline',
                          [input])
        return resp[0]

    def annotate_plant_genome(self, input):
        resp = self._call('ProbModelSEED.annotate_plant_genome',
                          [input])
        return resp[0]

    def create_featurevalues_from_shock(self, input):
        resp = self._call('ProbModelSEED.create_featurevalues_from_shock',
                          [input])
        return resp[0]

    def ModelReconstruction(self, input):
        resp = self._call('ProbModelSEED.ModelReconstruction',
                          [input])
        return resp[0]

    def FluxBalanceAnalysis(self, input):
        resp = self._call('ProbModelSEED.FluxBalanceAnalysis',
                          [input])
        return resp[0]

    def GapfillModel(self, input):
        resp = self._call('ProbModelSEED.GapfillModel',
                          [input])
        return resp[0]

    def MergeModels(self, input):
        resp = self._call('ProbModelSEED.MergeModels',
                          [input])
        return resp[0]

    def ImportKBaseModel(self, input):
        resp = self._call('ProbModelSEED.ImportKBaseModel',
                          [input])
        return resp[0]

    def CheckJobs(self, input):
        resp = self._call('ProbModelSEED.CheckJobs',
                          [input])
        return resp[0]
