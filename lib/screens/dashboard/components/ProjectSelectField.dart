// Copyright 2020 Kenton Hamaluik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecop/blocs/projects/bloc.dart';
import 'package:timecop/components/ProjectColour.dart';
import 'package:timecop/l10n.dart';
import 'package:timecop/models/project.dart';
import 'package:timecop/screens/dashboard/bloc/dashboard_bloc.dart';

class ProjectSelectField extends StatefulWidget {
  const ProjectSelectField({Key? key}) : super(key: key);

  @override
  State<ProjectSelectField> createState() => _ProjectSelectFieldState();
}

class _ProjectSelectFieldState extends State<ProjectSelectField> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    return BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (BuildContext context, ProjectsState projectsState) {
      return BlocBuilder<DashboardBloc, DashboardState>(
        bloc: bloc,
        builder: (BuildContext context, DashboardState state) {
          // detect if the project we had selected was deleted or archived
          if (state.newProject != null &&
              (projectsBloc.getProjectByID(state.newProject!.id) == null ||
                  projectsBloc
                      .getProjectByID(state.newProject!.id)!
                      .archived)) {
            bloc.add(const ProjectChangedEvent(null));
            return const IconButton(
              alignment: Alignment.centerLeft,
              icon: ProjectColour(project: null),
              onPressed: null,
            );
          }

          final projectName = state.newProject?.name;

          return IconButton(
            alignment: Alignment.centerLeft,
            icon: ProjectColour(project: state.newProject),
            tooltip: projectName != null
                ? "${L10N.of(context).tr.project} ($projectName)"
                : L10N.of(context).tr.project,
            onPressed: () async {
              _ProjectChoice? projectChoice = await showDialog<_ProjectChoice>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text(L10N.of(context).tr.projects),
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 16.0),
                      children: <Project?>[null]
                          .followedBy(
                              projectsState.projects.where((p) => !p.archived))
                          .map((Project? p) => TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(_ProjectChoice(p));
                              },
                              child: Row(
                                children: <Widget>[
                                  ProjectColour(project: p),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                    child: Text(
                                        p?.name ??
                                            L10N.of(context).tr.noProject,
                                        style: TextStyle(
                                            color: p == null
                                                ? Theme.of(context)
                                                    .disabledColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .color)),
                                  ),
                                ],
                              )))
                          .toList(),
                    );
                  });

              if (projectChoice != null) {
                bloc.add(ProjectChangedEvent(projectChoice.chosenProject));
              }
            },
          );
        },
      );
    });
  }
}

/// A class that stores the project that has been chosen by the user.
///
/// [chosenProject] may be `null` in case the user has chosen “(no project)”.
class _ProjectChoice {
  final Project? chosenProject;

  _ProjectChoice(this.chosenProject);
}
