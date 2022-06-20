import 'package:flutter/material.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubSummary extends StatefulWidget {
  const GitHubSummary({super.key, required this.github});
  final GitHub github;

  @override
  State<GitHubSummary> createState() => _GitHubSummaryState();
}

class _GitHubSummaryState extends State<GitHubSummary> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Octicons.repo),
              label: Text('Repositories'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.issue_opened),
              label: Text('Assigned Issues'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.git_pull_request),
              label: Text('Pull Requests'),
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          labelType: NavigationRailLabelType.selected,
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
        ),
        Expanded(
            child: IndexedStack(
          children: [
            RepositoriesList(github: widget.github),
            AssignedIssuesList(github: widget.github),
            PullRequestsList(github: widget.github),
          ],
        ))
      ],
    );
  }
}

class AssignedIssuesList extends StatefulWidget {
  const AssignedIssuesList({super.key, required this.github});
  final GitHub github;

  @override
  State<AssignedIssuesList> createState() => _AssignedIssuesListState();
}

class _AssignedIssuesListState extends State<AssignedIssuesList> {
  late Future<List<Issue>> _assignedIssues;

  @override
  void initState() {
    super.initState();
    _assignedIssues = widget.github.issues.listByUser().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Issue>>(
        future: null,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignedIssues = snapshot.data;

          return ListView.builder(
            itemBuilder: (context, index) {
              final currentIssue = assignedIssues![index];
              return ListTile(
                title: Text(currentIssue.title),
                subtitle: Text('${_nameWithOwner(currentIssue)}'
                    'Issue #${currentIssue.number}'
                    'opened by ${currentIssue.user?.login ?? 'unknown'}'),
                onTap: () => _launchUrl(context, currentIssue.htmlUrl),
              );
            },
            itemCount: assignedIssues?.length,
          );
        });
  }

  String _nameWithOwner(Issue assignedIssue) {
    final endIndex = assignedIssue.url.lastIndexOf('/issues/');
    return assignedIssue.url.substring(29, endIndex);
  }
}

class PullRequestsList extends StatefulWidget {
  const PullRequestsList({super.key, required this.github});
  final GitHub github;

  @override
  State<PullRequestsList> createState() => _PullRequestsListState();
}

class _PullRequestsListState extends State<PullRequestsList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RepositoriesList extends StatefulWidget {
  const RepositoriesList({super.key, required this.github});
  final GitHub github;
  @override
  State<RepositoriesList> createState() => _RepositoriesListState();
}

class _RepositoriesListState extends State<RepositoriesList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future<void> _launchUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final canLaunch = await canLaunchUrl(uri);
  if (canLaunch) {
    await launchUrl(uri);
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Navigation error'),
      content: Text('Could not launch $url'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    ),
  );
}
