class ApiConstants {
  static const String baseUrl = 'https://test.api.itisiya.com:8443/b2winai/';

//REGISTRATION
  static const String getRefreshToken = 'reg_auth/session/refresh_token';
  static const String loginEndpoint = 'reg_auth/sign_in/';
  static const String registerEndpoint = 'reg_auth/registration/register';
  static const String forgotPasswordOTPSendEndPoint =
      'reg_auth/otp/resend_password_reset_otp';
  static const String forgotPasswordChangeEndpoint = 'reg_auth/password/reset';
  // pending -- need to add content manager for the contest, or contest manager can perform

//PROFILE
  static const String userProfilePictureUpdate = 'profile/upload_profile_photo';
  static const String profilePictureDownloadEndpoint =
      'profile/download_profile_photo';
  // pending -- need to add  images , shots and other vedio  also for view the vedios
  //     and getting approval for uplaod to yutube shots

//ITMES  ( GALLERY -- BEFORE MATCH )
  static const String createContestEndpoint = 'item/contest/create';
  static const String createNoContestEndpoint =
      'scoring/contest/no_contest_create';
  static const String contestListEndpoint = 'item/contest/get_list';

  static const String createSingleMatchContestEndpoint =
      'item/contest/single_limited_over_play_match_contest_create';

  static const String addPlayerEndpoint = 'item/players/upload_player_file';
  static const String createPlayerEndpoint = 'item/players/player_create';
  static const String getPlayerInfoEndpoint = 'item/players/get';
  static const String getAllPlayersEndpoint =
      'item/players/get_all'; //( only for admin)
  static const String getPlayersEndpoint = 'item/players/get_own_players';
  static const String getPlayerByPhone = 'item/players/get_by_phone';

  static const String createTeamEndpoint = 'item/team/team_create';
  static const String uploadTeamLogoEndpoint = 'item/team/upload_team_logo';
  static const String downloadTeamLogoEndpoint = 'item/team/download_team_logo';
  static const String getTeamsEndPoint = 'item/team/get_teams';
  static const String getTeamInfoEndpoint = 'item/team/get_team_info';

  static const String addTeamSquardPlayerEndpoint = 'item/team/team_squad';
  static const String addPlayerToTeamEndpoint =
      'item/team/upload_team_squad_file';
  static const String getPlayerByTeamEndpoint = 'item/team/get_team_squad';

  static const String createMatchByFileEndpoint =
      'item/match_fixture/upload_fixture_file';
  static const String createMatchEndpoint = 'item/single_match/create_match';
  static const String getSingleMatchesEndPoint =
      'item/match_fixture/single_match_fixture';
  static const String getMatchInfoEndpoint = 'item/fixture/get_matchinfo';
  static const String getMatchPlayers = 'item/match_squard/get_match_squad';

//SCORING   ( GROUND HAPPNING)
  static const String addMatchSquardPlayerEndpoint =
      'scoring/match/add_match_squard';

  static const String tossDetaileEndpoint =
      'scoring/match/update_toss_and_over'; //change to put type --done
  static const String endMatchEndpoint = 'scoring/match/end_match';
  static const String updateMatchInningsStatusEndPoint =
      'scoring/match/update_innings_status'; //(change in variables, rework has to be done) --done
  static const String endOfFirstInningsEndPoint =
      'scoring/match/match_end_first_and_start_second_match_innigs'; //new API implemention --done

  static const String updateScoreEndpoint =
      'scoring/scoring/add_scoring'; //(change in variables, rework has to be done) --done
  static const String undoEndpoint =
      'scoring/scoring/undo_scoring'; //(change in variables, rework has to be done)
  static const String setNewBatsmanEndPoint =
      'scoring/match/new_batsman'; //new API implemention --done
  static const String setNewBowlerEndPoint =
      'scoring/match/new_bowler'; //new API implemention --done
  static const String getLatestBallID =
      'scoring/scoring/latest_scoring'; //new API implemention --done
  static const String startMatchEndpoint =
      'scoring/match/start_match'; //new API implemention --done

//SCOREBOARD  ( GROOUND FETCHING)
  static const String getScoreEndpoint = 'score_board/score/score_summary';
  static const String getTossDetailsEndpoint =
      'score_board/innings/innings_summary'; //API doesnot exist whole mechanism will fail --done
  static const String getScoreBoardEndpoint =
      'score_board/scoreboard/scoreboard_summary';
  static const String getBatsmanScoreEndpoint =
      'score_board/batsman/batsman_score'; //API doesnot exist whole mechanism will fail --done
  static const String getExtrasEndpoint =
      'score_board/scoring/extra_scoring_summary';
  static const String getFallOfWicketsEndpoint =
      'score_board/scoring/scoring_wicket_fall_summary';
  static const String getBallingScoreEndpoint =
      'score_board/scoring/scoring_summary';

  static const String getBestPerformanceEndpoint =
      'score_board/stat/best_performance_summary';
  static const String getMvpEndpoint =
      'score_board/stat/most_valuable_player_summary';

//Live Streaming APIs
  static const String createStreamEvent = 'streaming/stream/create_event';
  static const String getRmtpStreamUrl = 'streaming/stream/stream_url';
  static const String getYtStreamUrl = 'streaming/stream/watch_url';

//later to be removed
  // static const defaultContestId =
  //     2; //This is the noContestId to be used all over the app.
}
