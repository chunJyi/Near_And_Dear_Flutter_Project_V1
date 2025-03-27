import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.name ?? 'Unknown',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "Lat: ${user?.locationModel.latitude != null ? user!.locationModel.latitude.toStringAsFixed(4) : 'N/A'}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                "Lng: ${user?.locationModel.longitude != null ? user!.locationModel.longitude.toStringAsFixed(4) : 'N/A'}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (user?.locationModel.address != null) ...[
            Text(
              user!.locationModel.address,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
