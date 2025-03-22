class ApiConstants {
  static const String baseUrl = 'https://test.api.itisiya.com:8443/b2winai/';
  static const String getRefreshToken = 'reg_auth/session/refresh_token';
  static const String loginEndpoint = 'reg_auth/sign_in/';
  static const String registerEndpoint = 'reg_auth/registration/register';
  static const String forgotPasswordOTPSendEndPoint =
      'reg_auth/otp/resend_password_reset_otp';
  static const String forgotPasswordChangeEndpoint = 'reg_auth/password/reset';
  static const String createContestEndpoint = 'scoring/contest/create';
  static const String contestListEndpoint = 'scoring/contest/list';
  static const String getPlayersEndpoint = 'scoring/players/get_all';
  static const String getPlayerByTeamEndpoint =
      'score_board/team/get_team_squad';
  static const String createTeamEndpoint = 'scoring/team/team_create';
  static const String addTeamSquardPlayerEndpoint =
      'scoring/team/team_squad_json';
  static const String addMatchSquardPlayerEndpoint =
      'scoring/match/add_match_squard';
  static const String getTeamsEndPoint = 'score_board/team/get_teams';
  static const String createMatchByFileEndpoint =
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
  static const String undoEndpoint =
      'scoring/ball_score/reverse_last_ball_score';
  static const String tossDetaileEndpoint =
      'scoring/match/update-toss-and-overs';

  static const String getTossDetailsEndpoint = 'scoring/match/match_innings';

  static const String getPlayerInfoEndpoint = 'scoring/players/get';
  static const String userProfilePictureUpdate = 'profile/upload_profile_photo';
  static const String profilePictureDownloadEndpoint =
      'profile/download_profile_photo';
  static const String createNoContestEndpoint =
      'scoring/contest/no_contest_create';
  static const String uploadTeamLogoEndpoint = 'scoring/team/upload_team_logo';
  static const String downloadTeamLogoEndpoint =
      'scoring/team/download_team_logo';
  static const String getTeamInfoEndpoint = 'score_board/team/get_team_info';
  static const defaultContestId =
      2; //This is the noContestId to be used all over the app.
  static const String getPlayerByPhone = 'scoring/players/get_by_phone';
  static const String createPlayerEndpoint = 'scoring/players/player_create';
  static const String createMatchEndpoint =
      'scoring/match_fixture/match_create';
}
