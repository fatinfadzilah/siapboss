import 'package:flutter/widgets.dart';
import 'package:siapbos/Model/LoginModel.dart';

class SessionLoginProvider extends ChangeNotifier
{
  LoginModel _currentSession = new LoginModel();

  LoginModel get currentSession => _currentSession;

  setSession(LoginModel data) async
  {
    _currentSession = data;
    notifyListeners();
  }

  doneSetupBiometric()
  {
    return this._currentSession.isSetupBio;
  }

  removeSession() async
  {
    this._currentSession = new LoginModel();
  }
}