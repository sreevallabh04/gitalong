// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:gitalong/data/datasources/firebase_datasource.dart' as _i611;
import 'package:gitalong/data/datasources/github_api_datasource.dart' as _i899;
import 'package:gitalong/domain/repositories/auth_repository.dart' as _i212;
import 'package:gitalong/domain/repositories/match_repository.dart' as _i785;
import 'package:gitalong/domain/usecases/auth/get_current_user_usecase.dart'
    as _i33;
import 'package:gitalong/domain/usecases/auth/sign_in_with_github_usecase.dart'
    as _i612;
import 'package:gitalong/domain/usecases/swipe/get_potential_matches_usecase.dart'
    as _i451;
import 'package:gitalong/domain/usecases/swipe/record_swipe_usecase.dart'
    as _i347;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i33.GetCurrentUserUseCase>(
      () => _i33.GetCurrentUserUseCase(gh<_i212.AuthRepository>()),
    );
    gh.factory<_i612.SignInWithGitHubUseCase>(
      () => _i612.SignInWithGitHubUseCase(gh<_i212.AuthRepository>()),
    );
    gh.factory<_i451.GetPotentialMatchesUseCase>(
      () => _i451.GetPotentialMatchesUseCase(gh<_i785.MatchRepository>()),
    );
    gh.factory<_i347.RecordSwipeUseCase>(
      () => _i347.RecordSwipeUseCase(gh<_i785.MatchRepository>()),
    );
    gh.factory<_i899.GitHubApiDataSource>(
      () => _i899.GitHubApiDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i611.FirebaseDataSource>(
      () => _i611.FirebaseDataSource(gh<_i974.FirebaseFirestore>()),
    );
    return this;
  }
}
