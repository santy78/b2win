class ApiConstants {
  static const String baseUrl = 'https://test.api.itisiya.com:8443/b2winai/';
  static const String getRefreshToken = 'reg_auth/session/refresh_token';
  static const String loginEndpoint = 'reg_auth/sign_in/';
  static const String registerEndpoint = 'reg_auth/registration/register';
  static const String forgotPasswordOTPSendEndPoint =
      'reg_auth/otp/resend_password_reset_otp';
  static const String forgotPasswordChangeEndpoint = 'reg_auth/password/reset';
  static const String contestListEndpoint = 'scoring/contest/list';
  static const String createTeamEndpoint = 'scoring/team/upload_team_file';
  static const String getTeamsEndPoint = 'score_board/team/get_teams';
  static const String createMatchEndpoint =
      'scoring/match_fixture/upload_fixture_file';

  static const String getMatchesEndPoint = 'score_board/matches/get_matches';
  static const String addPlayerEndpoint = 'scoring/players/upload_player_file';
  static const String addPlayerToTeamEndpoint =
      'scoring/team/upload_team_squad_file';
  static const String updateScoreEndpouint = 'scoring/ball_score/create';
  static const String getScoreEndpoint = 'scoring/score/match/score';
  static const String getScoreBoardEndpoint = 'scoring/score/match/scoreboard';
  static const String getMatchPlayers = 'score_board/matches/playing_squad';
  static const String getBatsmanScoreEndpoint =
      'scoring/score/match/batsman_score';
  static const String getBallingScoreEndpoint =
      'scoring/score/match/ball_score';
}
