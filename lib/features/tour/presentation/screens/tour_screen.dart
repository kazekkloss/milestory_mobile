import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core_export.dart';
import '../tour_bloc/tour_bloc.dart';

class TourScreen extends StatefulWidget {
  const TourScreen({super.key});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  late TourBloc _tourBloc;

  @override
  void initState() {
    _tourBloc = context.read<TourBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlobalErrorListener(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                AppTextFormField(
                  descriptionText: 'Szukaj trasy',
                  hintText: 'Wpisz nazwę trasy',
                  suffixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    _tourBloc.add(SearchTourEvent(query: value));
                  },
                ),
                Expanded(
                  child: BlocBuilder<TourBloc, TourState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.searchedTours.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ListView.builder(
                        itemCount: state.searchedTours.length,
                        itemBuilder: (context, index) {
                          final tour = state.searchedTours[index];
                          return ListTile(
                            title: Text(tour.title),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
