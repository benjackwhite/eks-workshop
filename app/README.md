# Kubernetes Workshop Example App

This container is designed for use as part of a Kubernetes workshop (https://github.com/benjackwhite/eks-workshop).

It offers a simple set of endpoints to demonstrate how different features of Kubernetes can be used to successfully deploy production applications

### Usage

#### Environment Variables

* `REDIS_URL` - The url of the target Redis for `/messages` endpoints (e.g. redis://redis.default:6379)
* `PORT` - The port that the app will run on
* `MESSAGE` - A simple string to be displayed in the root response
* `MESSAGES_REDIS_KEY` - The key in redis where messages will be stored (default: `messages`)


## Find Us

* [GitHub](https://github.com/benjackwhite/eks-workshop)

## Authors

* **Ben White** - *Initial work* - [benjackwhite](https://github.com/benjackwhite/)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

* Thanks for to [hello-kubernetes](https://github.com/paulbouwer/hello-kubernetes) for the initial inspiration
