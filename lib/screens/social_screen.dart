import 'package:flutter/material.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: const Text('Community'),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
                tooltip: 'Search',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Feed', icon: Icon(Icons.feed)),
                Tab(text: 'Groups', icon: Icon(Icons.groups)),
                Tab(text: 'Challenges', icon: Icon(Icons.emoji_events)),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            _buildGroupsTab(),
            _buildChallengesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        tooltip: 'Create post',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPostCard(
          context,
          userName: 'GreenWarriors',
          userAvatar: 'https://i.pravatar.cc/150?img=1',
          timeAgo: '2 hours ago',
          postText: 'Just finished our weekly neighborhood cleanup! ♻️ So proud of what we can achieve together. #WasteWise #CommunityAction',
          likes: '1.2k',
          comments: '88',
          ecoReward: '50 ECO',
        ),
        _buildPostCard(
          context,
          userName: 'EcoAnna',
          userAvatar: 'https://i.pravatar.cc/150?img=2',
          timeAgo: '1 day ago',
          postText: 'Does anyone have creative ideas for upcycling plastic bottles? I have so many and want to give them a new life! 😊',
          likes: '234',
          comments: '15',
        ),
        _buildPostCard(
          context,
          userName: 'RecycleKing',
          userAvatar: 'https://i.pravatar.cc/150?img=3',
          timeAgo: '2 days ago',
          postText: 'Milestone achieved! 🎉 I\'ve recycled 500kg of waste this month. Thanks to everyone who supported my journey!',
          likes: '892',
          comments: '45',
          ecoReward: '100 ECO',
        ),
      ],
    );
  }

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildGroupCard(
          'Local Recycling Heroes',
          '1.2k members',
          'Join your neighborhood recycling community',
          Icons.recycling,
          Colors.green,
        ),
        _buildGroupCard(
          'Zero Waste Champions',
          '856 members',
          'Share tips for reducing waste in daily life',
          Icons.eco,
          Colors.blue,
        ),
        _buildGroupCard(
          'Upcycling Creators',
          '645 members',
          'Creative projects from recycled materials',
          Icons.build,
          Colors.orange,
        ),
        _buildGroupCard(
          'Corporate Green Teams',
          '234 members',
          'Workplace sustainability initiatives',
          Icons.business,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildChallengesTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildChallengeCard(
          'Weekly Plastic Challenge',
          'Recycle 50 plastic items this week',
          '5 days left',
          '150 ECO',
          0.7,
          Colors.blue,
        ),
        _buildChallengeCard(
          'Community Clean-up Drive',
          'Participate in local cleanup events',
          '2 days left',
          '500 ECO',
          0.3,
          Colors.green,
        ),
        _buildChallengeCard(
          'Zero Waste Weekend',
          'Generate zero waste for 48 hours',
          '10 days left',
          '300 ECO',
          0.0,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildGroupCard(String name, String members, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(members, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Join'),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildChallengeCard(String title, String description, String timeLeft, String reward, double progress, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emoji_events, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).toInt()}% Complete', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(reward, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(timeLeft, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your recycling story...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post created successfully!')),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context, {
    required String userName,
    required String userAvatar,
    required String timeAgo,
    String? postImage,
    required String postText,
    String? likes,
    String? comments,
    String? ecoReward,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: Theme.of(context).textTheme.titleSmall),
                      Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (ecoReward != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ecoReward,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (postImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(postImage, fit: BoxFit.cover, width: double.infinity),
              ),
              const SizedBox(height: 16),
            ],
            Text(postText),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReactionButton(Icons.favorite_border, likes ?? '0', () {}),
                _buildReactionButton(Icons.chat_bubble_outline, comments ?? '0', () {}),
                _buildReactionButton(Icons.share_outlined, '', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(IconData icon, String text, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
    );
  }
}
